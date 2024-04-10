# frozen_string_literal: true

module Reports
  class CrossAccountPercentActualByFocusArea < Base
    attr_reader :accounts

    def initialize(accounts)
      @accounts = accounts
      super()
    end

    def to_xlsx
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

          data.each do |row|
            sheet.add_row(
              [
                row['account_name'],
                row['scorecard_name'],
                row['initiative_name'],
                row['focus_area_name'],
                row['actual_characteristics'],
                row['total_characteristics'],
                row['percent_actual']
              ],
              style: styles[:blue_normal]
            )
          end

          sheet.column_widths(75.5, 10, 10)
        end
      end.to_stream
    end

    private

    def add_header(sheet, styles)
      sheet.add_row(
        ['Account', 'Transition Card', 'Initiative', 'Focus Area', 'Actual', 'Target', 'Percent Actual'],
        style: styles[:header_1]
      )
    end

    def generate_data
      sql = <<~SQL
        with raw_percent_actual_by_focus_area as (
          select
            accounts.id as account_id,
            scorecards.id as scorecard_id,
            initiatives.id as initiative_id,
            focus_areas.id as focus_area_id,
            count(checklist_items.id) as total_characteristics,
            sum(case when checklist_items.status = 'actual' then 1 else 0 end) as actual_characteristics,
            round(sum(case when checklist_items.status = 'actual' then 1 else 0 end)::numeric / count(checklist_items.id)::numeric * 100.0, 2) as percent_actual
          from checklist_items
            inner join initiatives on checklist_items.initiative_id = initiatives.id
            inner join scorecards on initiatives.scorecard_id = scorecards.id
            inner join accounts on scorecards.account_id = accounts.id
            inner join characteristics on checklist_items.characteristic_id = characteristics.id
            inner join focus_areas on characteristics.focus_area_id = focus_areas.id
            where accounts.id in (#{accounts.pluck(:id).join(',')})
            and initiatives.deleted_at is null
            and scorecards.deleted_at is null
            and scorecards.type = 'TransitionCard'
            group by accounts.id, scorecards.id, initiatives.id, focus_areas.id
        )

        select
          accounts.name as account_name,
          scorecards.name as scorecard_name,
          scorecards.type as scorecard_type,
          initiatives.name as initiative_name,
          focus_areas.name as focus_area_name,
          raw_percent_actual_by_focus_area.total_characteristics,
          raw_percent_actual_by_focus_area.actual_characteristics,
          raw_percent_actual_by_focus_area.percent_actual
        from raw_percent_actual_by_focus_area
        inner join initiatives on raw_percent_actual_by_focus_area.initiative_id = initiatives.id
        inner join scorecards on initiatives.scorecard_id = scorecards.id
        inner join accounts on scorecards.account_id = accounts.id
        inner join focus_areas on raw_percent_actual_by_focus_area.focus_area_id = focus_areas.id
        order by account_name, scorecard_name, initiative_name, focus_areas.position
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
