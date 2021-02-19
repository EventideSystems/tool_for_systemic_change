require 'csv'

module Reports
  class ScorecardActivity
    attr_accessor :scorecard, :date_from, :date_to

    def initialize(scorecard, date_from, date_to)
      @scorecard = scorecard
      @date_from = date_from.beginning_of_day
      @date_to = date_to.end_of_day
    end

    def initiative_totals
      @initiative_totals ||= fetch_initiative_totals
    end

    def results
      @results ||= characteristics.inject([]) do |result, characteristic|
        result << {
          characteristic: characteristic.name,
          comment_updates: comment_updates_for_characteristic(characteristic)
        }.merge(checklist_item_counts_for_characteristic(characteristic))
      end
    end

    def to_xlsx
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'

        header_1 = p.workbook.styles.add_style fg_color: '386190', sz: 16, b: true
        header_2 = p.workbook.styles.add_style bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: true
        header_3 = p.workbook.styles.add_style bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: false
        blue_normal = p.workbook.styles.add_style fg_color: '386190', sz: 12, b: false
        wrap_text = p.workbook.styles.add_style alignment: { horizontal: :general, vertical: :bottom, wrap_text: true }
        date = p.workbook.styles.add_style format_code: 'd/m/yy'

        p.workbook.add_worksheet(name: 'Report') do |sheet|
          sheet
            .add_row([Scorecard.model_name.human.to_s], style: header_1)
            .add_cell(scorecard.name, style: blue_normal)
          sheet.add_row(['Date range'], b: true).tap do |row|
            row.add_cell(date_from, style: date)
            row.add_cell(date_to - 1.second, style: date)
          end

          sheet.add_row(['Report generated on']).tap do |row|
            row.add_cell(DateTime.now, style: date)
          end

          sheet.add_row
          sheet.add_row(
            [
              '',
              'Initiatives beginning of period',
              'Additions',
              'Removals',
              'Initiatives end of period',
              'Initiative comment updates'
            ],
            height: 48, style: wrap_text
          )

          sheet.add_row([
                          "Total #{Scorecard.model_name.human} Initiatives",
                          initiative_totals[:initial],
                          initiative_totals[:additions],
                          initiative_totals[:removals],
                          initiative_totals[:final],
                          initiative_totals[:comment_updates]
                        ], style: header_1)

          sheet.add_row do |row|
            row.add_cell('Initiative Characteristics', style: header_1)
            row.add_cell('Characteristics beginning of period', height: 48, style: wrap_text)
            row.add_cell('Additions', height: 48, style: wrap_text)
            row.add_cell('Removals', height: 48, style: wrap_text)
            row.add_cell('Characteristics end of period', height: 48, style: wrap_text)
            row.add_cell('Characteristic comment updates', height: 48, style: wrap_text)
          end

          current_focus_area_group = ''
          current_focus_area = ''

          results.each do |result|
            if result[:focus_area_group] != current_focus_area_group
              current_focus_area_group = result[:focus_area_group]
              current_focus_area = ''
              sheet.add_row [result[:focus_area_group], '', '', '', '', ''], style: header_2
            end

            if result[:focus_area] != current_focus_area
              current_focus_area = result[:focus_area]
              sheet.add_row ["\s\s" + result[:focus_area], '', '', '', '', ''], style: header_3
            end

            sheet.add_row(
              [
                "\s\s\s\s" + result[:characteristic],
                result[:initial],
                result[:additions],
                result[:removals],
                result[:final],
                result[:comment_updates]
              ]
            )
          end

          sheet.column_widths 75.5, 10, 10, 10, 10
        end
      end.to_stream
    end

    private

    INITIATIVE_TOTALS_SQL = <<~SQL.freeze
      select
        count(initiatives.id) filter(
          where (deleted_at IS NULL OR deleted_at >= $1) AND created_at < $1
        ) as initial,
        count(initiatives.id) filter(
          where (deleted_at IS NULL OR deleted_at >= $2) AND created_at BETWEEN $1 AND $2
        ) as additions,
        count(initiatives.id) filter(
          where deleted_at BETWEEN $1 AND  $2
        ) as removals
      from initiatives where scorecard_id=$3
    SQL

    INITIATIVE_COMMENT_UPDATE_TOTALS_SQL = <<~SQL.freeze
      select 
        count(distinct(initiatives.id))
      from checklist_items
      inner join checklist_item_comments
        on checklist_item_comments.checklist_item_id = checklist_items.id
        AND checklist_item_comments.comment <> ''
        AND checklist_item_comments.comment IS NOT NULL
      inner join checklist_item_comments other_comments 
        on other_comments.checklist_item_id = checklist_item_comments.checklist_item_id
        and other_comments.id <> checklist_item_comments.id
        AND other_comments.comment <> ''
        AND other_comments.comment IS NOT NULL
      inner join initiatives on initiatives.id = checklist_items.initiative_id
      where
        checklist_item_comments.created_at BETWEEN $1 AND $2
        AND checklist_item_comments.comment <> ''
        AND checklist_item_comments.comment IS NOT NULL
        AND initiatives.scorecard_id=$3
      having (count(distinct(checklist_item_comments.id)) > 1)
    SQL

    CHARACTERISTIC_COMMENT_UPDATES_SQL = <<~SQL.freeze
      select 
        checklist_items.characteristic_id, 
        count(distinct(checklist_item_comments.id)) as count 
      from checklist_items
      inner join checklist_item_comments
        on checklist_item_comments.checklist_item_id = checklist_items.id
        and checklist_item_comments.comment <> ''
        and checklist_item_comments.comment IS NOT NULL
      left join checklist_item_comments all_comments 
        on all_comments.checklist_item_id = checklist_items.id
        and all_comments.comment <> ''
        and all_comments.comment IS NOT NULL
      inner join initiatives 
        on initiatives.id = checklist_items.initiative_id
      where
        checklist_item_comments.created_at BETWEEN $1 AND $2
        and initiatives.scorecard_id=$3
      group by checklist_items.characteristic_id
      having (count(distinct(all_comments.id)) > 1);
    SQL

    CHECKLIST_ITEM_COUNTS_SQL = <<~SQL.freeze
      select
        focus_area_groups.name as focus_area_group,
        focus_areas.name as focus_area,
        checklist_items.characteristic_id,
        count(distinct(checklist_items.id)) filter(
          where checklist_item_comments.created_at < $1
          or checklist_item_at_time(checklist_items.id, $1) = true
        ) as initial,
        count(distinct(checklist_items.id)) filter(
          where (
            checklist_item_comments.created_at BETWEEN $1 AND $2
            or checklist_item_at_time(checklist_items.id, $2) = true
          ) and not (
            checklist_item_comments.created_at < $1
          ) and not (
            checklist_item_at_time(checklist_items.id, $1) = true
          )
        ) as additions,
        count(distinct(checklist_items.id)) filter(
          where (
            checklist_item_comments.created_at < $1
            or checklist_item_at_time(checklist_items.id, $1) = true
          ) and not (
            checklist_item_comments.created_at > $1
          ) and not (
            checklist_item_at_time(checklist_items.id, $2) = true
          )
        ) as removals
      from initiatives
      inner join checklist_items
        on checklist_items.initiative_id = initiatives.id
      left join checklist_item_comments
        on checklist_item_comments.checklist_item_id = checklist_items.id
        and checklist_item_comments.comment <> ''
        and checklist_item_comments.comment is not null
      inner join characteristics 
        on characteristics.id = checklist_items.characteristic_id
      inner join focus_areas 
        on focus_areas.id = characteristics.focus_area_id
      inner join focus_area_groups 
        on focus_area_groups.id = focus_areas.focus_area_group_id
      where scorecard_id=$3
      group by focus_area_groups.name, focus_areas.name, checklist_items.characteristic_id    
    SQL


    private_constant \
      :INITIATIVE_TOTALS_SQL, 
      :CHARACTERISTIC_COMMENT_UPDATES_SQL

    def build_common_bind_vars
      [
        ActiveRecord::Relation::QueryAttribute.new('date_from', date_from, ActiveRecord::Type::DateTime.new),
        ActiveRecord::Relation::QueryAttribute.new('date_to', date_to, ActiveRecord::Type::DateTime.new),
        ActiveRecord::Relation::QueryAttribute.new('scorecard_id', scorecard.id, ActiveRecord::Type::Integer.new)
      ]
    end

    def characteristics
      Characteristic.joins(focus_area: :focus_area_group).order('focus_area_groups.position, focus_areas.position')
    end

    def initiatives(date_from, date_to)
      @initiatives ||= fetch_initiatives(date_from, date_to)
    end

    def initiative_comment_updates
      @initiative_comment_updates ||= fetch_initiative_comment_updates
    end

    def characteristic_comment_updates
      @characteristic_comment_updates ||= fetch_characteristic_comment_updates
    end

    def comment_updates_for_characteristic(characteristic)
      update = characteristic_comment_updates.find do |comment_update|
        comment_update['characteristic_id'] == characteristic.id
      end

      update.present? ? update['count'] : 0
    end

    def checklist_item_counts_for_characteristic(characteristic)
      checklist_item_counts.find do |item_counts|
        item_counts[:characteristic_id] == characteristic.id
      end
    end

    def fetch_initiatives(date_from, date_to)
      params = { date_from: date_from, date_to: date_to }

      scorecard.initiatives
               .with_deleted
               .where('finished_at IS NULL or finished_at >= :date_from', params)
               .where('started_at IS NULL or started_at <= :date_to', params)
    end

    def fetch_initiative_comment_updates
      ApplicationRecord.connection.exec_query(
        INITIATIVE_COMMENT_UPDATE_TOTALS_SQL,
        '-- INITIATIVE COMMENT UPDATES --',
        build_common_bind_vars,
        prepare: true
      ).first.then do |comment_updates|
        { comment_updates:  comment_updates&.dig('count') || 0 }
      end
    end

    def fetch_initiative_totals
      ApplicationRecord.connection.exec_query(
        INITIATIVE_TOTALS_SQL,
        '-- INITIATIVE TOTALS --',
        build_common_bind_vars,
        prepare: true
      ).first.then do |totals|
        totals.symbolize_keys!
        totals[:final] = totals[:initial] + totals[:additions] - totals[:removals]
        totals.merge!(fetch_initiative_comment_updates)
        totals
      end
    end

    def fetch_characteristic_comment_updates
      ApplicationRecord.connection.exec_query(
        CHARACTERISTIC_COMMENT_UPDATES_SQL,
        '-- INITIATIVE COMMENT UPDATES --',
        build_common_bind_vars,
        prepare: true
      )
    end

    def fetch_checklist_item_counts
      ApplicationRecord.connection.exec_query(
        CHECKLIST_ITEM_COUNTS_SQL,
        '-- CHECKLIST ITEM COUNTS --',
        build_common_bind_vars,
        prepare: true
      ).to_a.map(&:symbolize_keys).map do |counts|
        counts[:final] = counts[:initial] + counts[:additions] - counts[:removals]
        counts
      end
    end

    def checklist_item_counts
      @checklist_item_counts ||= fetch_checklist_item_counts
    end 
  end
end
