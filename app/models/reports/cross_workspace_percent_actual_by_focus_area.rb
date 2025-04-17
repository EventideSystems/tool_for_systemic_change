# frozen_string_literal: true

module Reports
  # This class is responsible for generating a report of the percent of actual characteristics by focus area
  class CrossWorkspacePercentActualByFocusArea < Base
    attr_reader :workspaces

    def initialize(workspaces)
      @workspaces = workspaces
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

        p.workbook.add_worksheet(name: 'Report') do |sheet|
          add_header(sheet, styles)

          data = generate_data

          data.each do |row|
            sheet.add_row(
              [
                row['workspace_name'],
                row['impact_card_name'],
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
        ['Workspace', 'Impact Card', 'Initiative', 'Focus Area', 'Actual', 'Target', 'Percent Actual'],
        style: styles[:header_1] # rubocop:disable Naming/VariableNumber
      )
    end

    # SMELL Explicit reference to impact_card_data_models.name = 'Transition Card'
    def generate_data # rubocop:disable Metrics/MethodLength
      sql = <<~SQL
        with raw_percent_actual_by_focus_area as (
          select
            workspaces.id as workspace_id,
            scorecards.id as scorecard_id,
            initiatives.id as initiative_id,
            focus_areas.id as focus_area_id,
            count(checklist_items.id) as total_characteristics,
            sum(case when checklist_items.status = 'actual' then 1 else 0 end) as actual_characteristics,
            round(sum(case when checklist_items.status = 'actual' then 1 else 0 end)::numeric / count(checklist_items.id)::numeric * 100.0, 2) as percent_actual
          from checklist_items
            inner join initiatives on checklist_items.initiative_id = initiatives.id
            inner join scorecards on initiatives.scorecard_id = scorecards.id
            inner join workspaces on scorecards.workspace_id = workspaces.id
            inner join characteristics on checklist_items.characteristic_id = characteristics.id
            inner join focus_areas on characteristics.focus_area_id = focus_areas.id
            inner join impact_card_data_models on scorecards.impact_card_data_model_id = impact_card_data_models.id
            where workspaces.id in (#{workspaces.pluck(:id).join(',')})
            and initiatives.deleted_at is null
            and scorecards.deleted_at is null
            and impact_card_data_models.name = 'Transition Card'
            group by workspaces.id, scorecards.id, initiatives.id, focus_areas.id
        )

        select
          workspaces.name as workspace_name,
          scorecards.name as impact_card_name,
          initiatives.name as initiative_name,
          focus_areas.name as focus_area_name,
          raw_percent_actual_by_focus_area.total_characteristics,
          raw_percent_actual_by_focus_area.actual_characteristics,
          raw_percent_actual_by_focus_area.percent_actual
        from raw_percent_actual_by_focus_area
        inner join initiatives on raw_percent_actual_by_focus_area.initiative_id = initiatives.id
        inner join scorecards on initiatives.scorecard_id = scorecards.id
        inner join workspaces on scorecards.workspace_id = workspaces.id
        inner join focus_areas on raw_percent_actual_by_focus_area.focus_area_id = focus_areas.id
        order by workspace_name, impact_card_name, initiative_name, focus_areas.position
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
