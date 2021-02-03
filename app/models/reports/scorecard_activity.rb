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
          focus_area_group: characteristic.focus_area.focus_area_group.name,
          focus_area: characteristic.focus_area.name,
          characteristic: characteristic.name,
          comment_updates: initiative_comment_updates_for_characteristic(characteristic)
        }.merge(checklist_item_counts(characteristic, scorecard.initiatives.with_deleted, date_from, date_to))
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
          sheet.add_row([Scorecard.model_name.human.to_s], style: header_1).add_cell(scorecard.name, style: blue_normal)
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

    def to_csv
      current_focus_area_group = ''
      current_focus_area = ''

      CSV.generate do |csv|
        csv << [Scorecard.model_name.human.to_s, scorecard.name, '', '', '']
        csv << ['Dates range', date_from.strftime('%d/%m/%y'), date_to.strftime('%d/%m/%y'), '', '']
        csv << ['', '', '', '', '']

        csv << [
          '',
          'Initiatives beginning of period',
          'Additions',
          'Removals',
          'Initiatives end of period'
        ]

        results.each do |result|
          if result[:focus_area_group] != current_focus_area_group
            current_focus_area_group = result[:focus_area_group]
            current_focus_area = ''
            csv << [result[:focus_area_group], '', '', '', '']
          end

          if result[:focus_area] != current_focus_area
            current_focus_area = result[:focus_area]
            csv << ["\t\t" + result[:focus_area], '', '', '', '']
          end

          csv << ["\t\t\t\t" + result[:characteristic], result[:initial], result[:additions], result[:removals], result[:final]]
        end
      end
    end

    private

    INITIATIVE_TOTALS_SQL = <<~SQL.freeze
      select
        count(initiatives.id) filter(where (deleted_at IS NULL OR deleted_at >= $1) AND created_at < $1) as initial,
        count(initiatives.id) FILTER(where (deleted_at IS NULL OR deleted_at >= $2) AND created_at BETWEEN $1 AND $2) as additions,
        count(initiatives.id) filter(where deleted_at BETWEEN $1 AND  $2) as removals
      from initiatives where scorecard_id=$3
    SQL

    # NOTE: This is comments changed across intitiatives. If we need total number of times
    # a comment has changed, remove the 'distinct' from below
    INITIATIVE_COMMENT_UPDATES_SQL = <<~SQL.freeze
      select characteristic_id, count(distinct(checklist_items.*)) as count from checklist_items
      inner join versions
        on versions.item_id = checklist_items.id
        AND versions.item_type = 'ChecklistItem'
      inner join initiatives on initiatives.id = checklist_items.initiative_id
      where
        checklist_items.comment IS NOT NULL and checklist_items.comment <> ''
        AND versions.event = 'update'
        AND TRIM(substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) <> checklist_items.comment
        AND versions.created_at BETWEEN $1 AND  $2
        AND initiatives.scorecard_id=$3
      group by characteristic_id
    SQL

    # NOTE: Not in use, but some ideas on how to speed up creating the result
    INITIATIVE_CHECKED_UPDATES_SQL = <<~SQL.freeze
      select 
        checklist_items.id, 
        checklist_items.checked, 
        TRIM(substring(version_before.object from 'checked\:\strue')) <> '' as before
      from checklist_items
      left join (
        select distinct on (item_id) * from versions
        where item_type = 'ChecklistItem'
        and created_at < '2021-01-27'
        order by item_id, created_at desc
      ) as version_before
      on checklist_items.id = version_before.item_id

      left join (
        select distinct on (item_id) * from versions
        where item_type = 'ChecklistItem'
        and created_at between '2021-01-27' and '2021-01-28'
        order by item_id, created_at desc
      ) as version_during

      inner join initiatives on initiatives.id = checklist_items.initiative_id
      where initiatives.scorecard_id = 8;
    SQL

    private_constant \
      :INITIATIVE_TOTALS_SQL, 
      :INITIATIVE_COMMENT_UPDATES_SQL, 
      :INITIATIVE_CHECKED_UPDATES_SQL

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

    def initiative_comment_updates_for_characteristic(characteristic)
      update = initiative_comment_updates.find do |comment_update|
        comment_update['characteristic_id'] == characteristic.id
      end

      update.present? ? update['count'] : 0
    end

    def fetch_initiatives(date_from, date_to)
      params = { date_from: date_from, date_to: date_to }

      scorecard.initiatives
               .with_deleted
               .where('finished_at IS NULL or finished_at >= :date_from', params)
               .where('started_at IS NULL or started_at <= :date_to', params)
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
        totals[:comment_updates] = initiative_comment_updates.sum { |a| a['count'] }
        totals
      end
    end

    def fetch_initiative_comment_updates
      ApplicationRecord.connection.exec_query(
        INITIATIVE_COMMENT_UPDATES_SQL,
        '-- INITIATIVE COMMENT UPDATES --',
        build_common_bind_vars,
        prepare: true
      )
    end

    def fetch_all_checklist_item_counts
    
    end

    def checklist_item_counts(characteristic, initiatives, date_from, date_to)
      checklist_items = ChecklistItem.where(characteristic: characteristic, initiative: initiatives)

      item_counts = checklist_items.each_with_object({ initial: 0, additions: 0, removals: 0 }) do |item, counts|
        state_before_range = item.snapshot_at(date_from - 1.second).checked == true
        item.reload # Otherwise, item will equal last snapshot
        state_within_range = item.snapshot_at(date_to).checked == true

        counts[:initial]   += 1 if state_before_range == true
        counts[:additions] += 1 if state_within_range == true && state_before_range == false
        counts[:removals]  += 1 if state_within_range == false && state_before_range == true
      end

      item_counts[:final] = item_counts[:initial] + item_counts[:additions] - item_counts[:removals]
      item_counts
    end
  end
end
