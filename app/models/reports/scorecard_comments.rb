# frozen_string_literal: true

module Reports
  class ScorecardComments < Base
    attr_reader :scorecard, :date, :status, :time_zone

    def initialize(scorecard, date, status, time_zone)
      @scorecard = scorecard
      @date = date
      @status = status
      @time_zone = time_zone
    end

    def initiatives
      @initiatives ||= fetch_initiatives(date)
    end

    def to_xlsx
      padding_plus_2 = Array.new(initiatives.count + 2, '')

      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'

        styles = {
          header_1: p.workbook.styles.add_style(fg_color: '386190', sz: 16, b: true),
          header_2: p.workbook.styles.add_style(bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: true),
          header_3: p.workbook.styles.add_style(bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: false),
          blue_normal: p.workbook.styles.add_style(fg_color: '386190', sz: 12, b: false),
          wrap_text: p.workbook.styles.add_style(
            alignment: {
              horizontal: :general,
              vertical: :bottom,
              wrap_text: true
            }
          ),
          date: date_style(p)
        }

        p.workbook.add_worksheet(name: 'Report') do |sheet|
          add_header(sheet, styles)

          data = generate_data

          FocusAreaGroup.where(scorecard_type: scorecard.type).order(:position).each do |focus_area_group|
            sheet.add_row([focus_area_group.name] + padding_plus_2, style: styles[:header_2])

            focus_area_group.focus_areas.order(:position).each do |focus_area|
              sheet.add_row(["  #{focus_area.name}"] + padding_plus_2, style: styles[:header_3])

              focus_area.characteristics.order(:position).each do |characteristic|
                data_row = data[characteristic.id]

                initiative_comments = \
                  if data_row.present?
                    initiatives.map do |initiative|
                      comment_data = data_row[:comments].find { |d| d[:initiative_id] == initiative.id }

                      next '' if comment_data.blank?

                      comment_data[:comments]
                        .sort_by { |c| c[:date] }
                        .reverse
                        .map { |c| "[#{utc_date_time_string_to_date_time(c[:date])}] #{c[:comment]}" }
                        .join('; ')
                    end
                  else
                    initiative_comments = initiatives.map { '' }
                  end

                sheet.add_row(
                  [
                    "    #{characteristic.name}",
                    data_row&.dig(:initiative_count) || 0,
                    data_row&.dig(:initiative_comment_count) || 0
                  ] + initiative_comments
                )
              end
            end
          end

          sheet.column_widths(75.5, 10, 10)
        end
      end.to_stream
    end

    private

    def add_header(sheet, styles)
      sheet.add_row([Time.now], style: styles[:date])

      sheet.add_row([scorecard.model_name.human], style: styles[:header_1]).add_cell(
        scorecard.name,
        style: styles[:blue_normal]
      )
      sheet.add_row(['Date'], b: true).tap do |row|
        row.add_cell(date, style: styles[:date])
      end
      sheet.add_row(['Status'], b: true).tap do |row|
        row.add_cell(status.titleize)
      end

      sheet.add_row

      sheet.add_row(['', 'Total initiatives', 'Total comments'] + initiatives.map(&:name))
    end

    def utc_date_time_string_to_date_time(date_str)
      Time.parse("#{date_str} +00:00").in_time_zone(time_zone).strftime('%Y-%m-%d %H:%M %Z')
    end

    def generate_data
      sql = <<~SQL
        with comments_with_timestamp as (
          select
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            json_strip_nulls(
              json_agg(
                json_build_object(
                  'comment', checklist_item_changes.comment,
                  'date', checklist_item_changes.created_at
                )
              )
            ) AS comments,
            count(checklist_item_changes.comment) as comment_count
          from checklist_item_changes
          inner join checklist_items on checklist_items.id = checklist_item_changes.checklist_item_id
          inner join characteristics on characteristics.id = checklist_items.characteristic_id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join lateral (
            select
              distinct on (previous_changes.checklist_item_id)
              previous_changes.id,
              previous_changes.comment
            from checklist_item_changes previous_changes
              where previous_changes.checklist_item_id = checklist_item_changes.checklist_item_id
              and previous_changes.created_at < checklist_item_changes.created_at
              order by previous_changes.checklist_item_id, previous_changes.created_at desc
          ) previous_changes on true
          where checklist_item_changes.comment <> coalesce(previous_changes.comment, '')
          and checklist_item_changes.created_at <= '#{date}'
          and checklist_item_changes.ending_status = '#{status}'
          and initiatives.scorecard_id = #{scorecard.id}
          group by characteristics.id, initiatives.id
        ),

        characteristics_ordered_by_position as (
          select
            characteristics.*
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          order by focus_area_groups.position, focus_areas.position, characteristics.id
        )

        select
          characteristics.id as characteristic_id,
          json_strip_nulls(
            json_agg(
              json_build_object(
                'initiative_id', initiative_id,
                'comments', comments,
                'comment_count', comment_count
              )
            )
          ) as comments,
          count(initiative_id) as initiative_count
        from characteristics
        inner join comments_with_timestamp on comments_with_timestamp.characteristic_id = characteristics.id
        group by characteristics.id
      SQL

      ActiveRecord::Base.connection.execute(sql).each_with_object({}) do |result, hash|
        hash[result['characteristic_id']] = {
          comments: JSON.parse(result['comments']),
          initiative_count: result['initiative_count']
        }.tap do |data|
          data[:initiative_comment_count] = data[:comments].sum { |c| c['comment_count'] }
        end.with_indifferent_access
      end
    end

    def fetch_initiatives(date)
      params = { date: date }

      scorecard.initiatives
               .where('started_at <= :date OR started_at IS NULL', params)
               .where('finished_at >= :date OR finished_at IS NULL', params)
    end
  end
end
