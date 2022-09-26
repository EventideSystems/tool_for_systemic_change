# frozen_string_literal: true

require 'csv'

module Reports
  class NewTransitionCardActivity < Base
    attr_accessor :scorecard, :date_from, :date_to
    attr_reader :initiative_totals

    def initialize(scorecard, date_from, date_to)
      @scorecard = scorecard
      @date_from = date_from
      @date_to = date_to
    end

    def to_xlsx
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'

        header_1 = header_1_style(p)
        header_2 = header_2_style(p)
        header_3 = header_3_style(p)
        blue_normal = blue_normal_style(p)
        wrap_text = wrap_text_style(p)
        date = date_style(p)

        p.workbook.add_worksheet(name: 'Report') do |sheet|
          add_report_header(sheet, header_1, blue_normal, date)
          sheet.add_row
          add_initiative_columns_header(sheet, wrap_text)
          add_initiative_totals(sheet, header_1)
          add_characteristic_columns_header(sheet, header_1, wrap_text)

          data = NewTransitionCardChecklistItems.execute(scorecard.id, date_from, date_to)

          current_focus_area_group_name = ''
          current_focus_area_name = ''

          data.each do |row|
            if row[:focus_area_group_name] != current_focus_area_group_name
              current_focus_area_group_name = row[:focus_area_group_name]
              current_focus_area_name = ''
              sheet.add_row [row[:focus_area_group_name], '', '', '', '', ''], style: header_2
            end

            if row[:focus_area_name] != current_focus_area_name
              current_focus_area_name = row[:focus_area_name]
              sheet.add_row ["  #{row[:focus_area_name]}", '', '', '', '', ''], style: header_3
            end

            sheet.add_row(
              [
                "    #{row[:characteristic_name]}",
                row[:actual_count_before_period],
                row[:additions_count_during_period],
                row[:actual_count_after_period],
                row[:assigned_actuals_count_during_period]
              ]
            )
          end

          set_column_widths(sheet)
        end
      end.to_stream
    end

    private

    def add_characteristic_columns_header(sheet, header_1, wrap_text)
      col_base_name = \
        case scorecard
        when TransitionCard then 'Characteristics'
        when SustainableDevelopmentGoalAlignmentCard then 'Targets'
        end

      sheet.add_row do |row|
        row.add_cell(initiative_characteristics_title, style: header_1)
        row.add_cell("#{col_base_name} beginning of period", height: 48, style: wrap_text)
        row.add_cell('Additions', height: 48, style: wrap_text)
        row.add_cell("#{col_base_name} end of period", height: 48, style: wrap_text)
        row.add_cell('New Comments Saved assigned Actuals', height: 48, style: wrap_text)
      end
    end

    def add_initiative_columns_header(sheet, wrap_text)
      sheet.add_row(
        [
          '',
          'Initiatives beginning of period',
          'Additions',
          'Removals',
          'Initiatives end of period'
        ],
        height: 48, style: wrap_text
      )
    end

    def add_initiative_totals(sheet, header_1)
      sheet.add_row(
        [
          "Total #{scorecard.model_name.human} Initiatives",
          initiative_totals[:initial],
          initiative_totals[:additions],
          initiative_totals[:removals],
          initiative_totals[:final]
        ],
        style: header_1
      )
    end

    def add_report_header(sheet, header_1, blue_normal, date)
      sheet.add_row([DateTime.now], style: date)

      sheet
        .add_row([scorecard.model_name.human], style: header_1)
        .add_cell(scorecard.name, style: blue_normal)

      sheet.add_row(['Date range'], b: true).tap do |row|
        row.add_cell(date_from, style: date)
        row.add_cell(date_to - 1.second, style: date)
      end
    end

    def header_1_style(package)
      package.workbook.styles.add_style fg_color: '386190', sz: 16, b: true
    end

    def header_2_style(package)
      package.workbook.styles.add_style bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: true
    end

    def header_3_style(package)
      package.workbook.styles.add_style bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: false
    end

    def initiative_characteristics_title
      case scorecard
      when TransitionCard then 'Initiative Characteristics'
      when SustainableDevelopmentGoalAlignmentCard then 'Sustainable Development Goals'
      end
    end

    # TODO: Find a better name for this style
    def blue_normal_style(package)
      package.workbook.styles.add_style fg_color: '386190', sz: 12, b: false
    end

    def wrap_text_style(package)
      package.workbook.styles.add_style alignment: { horizontal: :general, vertical: :bottom, wrap_text: true }
    end

    def initiative_totals
      @initiative_totals ||= TotalTransitionCardInitiatives.execute(scorecard.id, date_from, date_to)
    end

    def set_column_widths(sheet)
      sheet.column_widths 75.5, 10, 10, 10, 10, 10
    end
  end
end
