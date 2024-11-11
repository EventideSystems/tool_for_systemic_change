# frozen_string_literal: true

module Reports
  # This class is responsible for generating a report of the percent of actual characteristics by focus area (tabbed)
  class CrossAccountPercentActualByFocusAreaTabbed < Base # rubocop:disable Metrics/ClassLength
    attr_reader :accounts

    MAX_SHEET_NAME_LENGTH = 27

    def initialize(accounts)
      @accounts = accounts
      super()
    end

    def to_xlsx # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      Axlsx::Package.new do |p| # rubocop:disable Metrics/BlockLength
        p.workbook.styles.fonts.first.name = 'Calibri'

        # rubocop:disable Naming/VariableNumber
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
        # rubocop:enable Naming/VariableNumber

        focus_area_names.each do |focus_area_name|
          p.workbook.add_worksheet(name: focus_area_name.truncate(MAX_SHEET_NAME_LENGTH)) do |sheet|
            sheet.add_row([focus_area_name], style: styles[:header_1]) # rubocop:disable Naming/VariableNumber
            sheet.add_row
            add_header(sheet, styles)

            data = generate_data(focus_area_name)

            data.each do |row|
              sheet.add_row(
                [
                  row['account_name'],
                  row['scorecard_name'],
                  row['initiative_name'],
                  row['actual_characteristics'],
                  row['total_characteristics'],
                  row['percent_actual']
                ],
                style: styles[:blue_normal]
              )
            end

            sheet.column_widths(75.5, 10, 10)
          end
        end
      end.to_stream
    end

    private

    def add_header(sheet, styles)
      sheet.add_row(
        ['Account', 'Transition Card', 'Initiative', 'Actual', 'Target', 'Percent Actual'],
        style: styles[:header_2] # rubocop:disable Naming/VariableNumber
      )
    end

    def focus_area_names
      accounts
        .first
        .focus_area_groups
        .where(scorecard_type: 'TransitionCard')
        .flat_map(&:focus_areas)
        .sort_by { |focus_area| [focus_area.focus_area_group.position, focus_area.position] }
        .map(&:name)
    end

    def generate_data(focus_area_name) # rubocop:disable Metrics/MethodLength
      sql = <<~SQL
        with raw_percent_actual_by_focus_area as (
          select
            accounts.id as account_id,
            scorecards.id as scorecard_id,
            initiatives.id as initiative_id,
            focus_areas.name as focus_area_name,
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
            and focus_areas.name = '#{focus_area_name}'
            group by accounts.id, scorecards.id, initiatives.id, focus_areas.name
        )

        select distinct on (account_name, scorecard_name, initiative_name, focus_area_name)
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
        inner join focus_areas on raw_percent_actual_by_focus_area.focus_area_name = focus_areas.name
        order by account_name, scorecard_name, initiative_name, focus_area_name
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
