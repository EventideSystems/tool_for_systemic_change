# frozen_string_literal: true

require 'prawn'
require 'prawn/table'

module Prawn
  # Support for PDF generation via Prawn
  # rubocop:disable Metrics/ModuleLength
  module ScorecardsHelper
    include ::ActionView::Helpers::TextHelper

    def focus_area_color(focus_area)
      return focus_area.actual_color if focus_area.actual_color.present?

      "##{%w[FD6E77 FADD83 FEA785 AFBFF5 84ACD4 74C4DF 71B9B9 7AE0CC 7FD4A0][focus_area.position - 1]}"
    end

    def focus_area_desaturated_color(focus_area)
      %w[C4A7A9 CAC5B3 CEBCB5 CBCED9 A4ACB4 9FAFB4 8E9C9C A3B7B3 A1B2A8][focus_area.position - 1]
    end

    def checklist_item_color_sdg_card(checklist_item)
      case checklist_item.status
      when 'actual' then checklist_item.focus_area.actual_color.delete('#')
      when 'planned' then checklist_item.focus_area.planned_color.delete('#')
      else
        'F8F8F8'
      end
    end

    def checklist_item_color_transition_card(checklist_item)
      case checklist_item.status
      when 'actual' then focus_area_color(checklist_item.focus_area)
      when 'planned' then focus_area_desaturated_color(checklist_item.focus_area)
      else
        'F8F8F8'
      end
    end

    def page_header(scorecard) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      img = Rails.root.join('app/assets/images/logo-pdf.png').to_s

      repeat(:all) do
        canvas do
          bounding_box([bounds.left + 30, bounds.top - 20], width: bounds.width - 60) do
            font_size(22)
            pad_top(8) do
              text("#{scorecard.model_name.human}: #{truncate(scorecard.name, length: 40)}", valign: :top)
            end
            image(img, position: :right, width: 97, vposition: :top)
          end
        end
      end
    end

    def focus_areas_header_sdgs_card(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, _index|
        {
          content: focus_area.short_name,
          colspan: focus_area.characteristics.count,
          text_color: focus_area.actual_color.delete('#'),
          align: :center,
          border_width: 0
        }
      end
    end

    def focus_areas_header_transition_card(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, _index|
        {
          content: "Focus Area #{focus_area.position}",
          colspan: focus_area.characteristics.count,
          text_color: focus_area_color(focus_area),
          align: :center,
          border_width: 0
        }
      end
    end

    def spacer_sdgs_card(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, _index|
        {
          content: '',
          colspan: focus_area.characteristics.count,
          borders: %i[top left right],
          border_lines: [:dotted],
          border_color: focus_area.actual_color.delete('#'),
          border_width: 1
        }
      end
    end

    def spacer_transition_card(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, _index|
        {
          content: '',
          colspan: focus_area.characteristics.count,
          borders: %i[top left right],
          border_lines: [:dotted],
          border_color: focus_area_color(focus_area),
          border_width: 1
        }
      end
    end

    def legend_keys_sdgs_card(focus_areas) # rubocop:disable Metrics/MethodLength
      [{ content: '', border_width: 0 }] +
        focus_areas.each_with_object([]) do |focus_area, memo|
          focus_area.characteristics.each_with_object(memo) do |characteristic, focus_area_memo|
            focus_area_memo.push(
              {
                content: characteristic.identifier,
                text_color: focus_area.actual_color.delete('#'),
                border_width: 0,
                align: :center,
                size: 8
              }
            )
          end
        end
    end

    def legend_keys_transition_card(focus_areas) # rubocop:disable Metrics/MethodLength
      [{ content: '', border_width: 0 }] +
        focus_areas.each_with_object([]) do |focus_area, memo|
          focus_area.characteristics.each_with_object(memo) do |characteristic, focus_area_memo|
            focus_area_memo.push(
              {
                content: characteristic.identifier,
                text_color: focus_area_color(focus_area),
                border_width: 0,
                align: :center,
                size: 8
              }
            )
          end
        end
    end

    def legend_sdg_card(focus_areas) # rubocop:disable Metrics/MethodLength
      move_down(30)
      focus_areas.each_with_index do |focus_area, _focus_area_index|
        move_down(5)
        formatted_text(
          [
            {
              text: focus_area.short_name.force_encoding('UTF-8'),
              styles: [:bold],
              color: focus_area.planned_color.delete('#')
            }
          ],
          leading: 6
        )
        focus_area.characteristics.each_with_index do |characteristic, _characteristic_index|
          formatted_text(
            [
              { text: characteristic.name.force_encoding('UTF-8') }
            ],
            indent_paragraphs: 10,
            size: 8,
            leading: 4
          )
        end
      end
    end

    def legend_transition_card(focus_areas) # rubocop:disable Metrics/MethodLength
      move_down(30)
      focus_areas.each_with_index do |focus_area, _focus_area_index|
        move_down(5)
        formatted_text(
          [
            {
              text: "Focus Area #{focus_area.position}",
              styles: [:bold],
              color: focus_area_color(focus_area)
            },
            { text: " - #{focus_area.name.force_encoding('UTF-8')}", size: 10 }
          ],
          leading: 6
        )
        focus_area.characteristics.each_with_index do |characteristic, _characteristic_index|
          formatted_text(
            [
              { text: characteristic.identifier, color: focus_area_color(focus_area) },
              { text: " - #{characteristic.name.force_encoding('UTF-8')}" }
            ],
            indent_paragraphs: 10,
            size: 8,
            leading: 4
          )
        end
      end
    end

    def data_sdg_card(initiatives, focus_areas) # rubocop:disable Metrics/MethodLength
      initiatives.map do |initiative|
        [
          {
            content: truncate(pdf_safe(initiative.name), length: 62, escape: false),
            text_color: '3C8DBC',
            border_width: 0,
            width: 300
          }
        ] + initiative.checklist_items_ordered_by_ordered_focus_area(focus_areas:).map do |checklist_item|
              { content: ' ', border_width: 2, border_color: 'FFFFFF' }.tap do |cell|
                cell[:background_color] = checklist_item_color_sdg_card(checklist_item)
              end
            end
      end
    end

    def data_transition_card(initiatives, focus_areas) # rubocop:disable Metrics/MethodLength
      initiatives.map do |initiative|
        [
          {
            content: truncate(pdf_safe(initiative.name), length: 62, escape: false),
            text_color: '3C8DBC',
            border_width: 0,
            width: 300
          }
        ] + initiative.checklist_items_ordered_by_ordered_focus_area(focus_areas:).map do |checklist_item|
              { content: ' ', border_width: 2, border_color: 'FFFFFF' }.tap do |cell|
                cell[:background_color] = checklist_item_color_transition_card(checklist_item)
              end
            end
      end
    end

    def page_numbering
      font_size(12)
      string = 'Page <page> of <total>'
      options = { at: [bounds.right - 150, 0], width: 150, align: :right, start_count_at: 1 }
      number_pages(string, options)
    end

    def formatted_date(date)
      if date.present?
        { text: date.strftime('%B %-d, %Y') }
      else
        { text: 'No data', styles: [:italic] }
      end
    end

    def formatted_description(description)
      if description.present?
        { text: pdf_safe(description) }
      else
        { text: 'No description', styles: [:italic] }
      end
    end

    def pdf_safe(text)
      fallback = { "\u014C" => 'O' }
      ActionView::Base.full_sanitizer.sanitize(text.encode('Windows-1252', fallback:)).gsub('&amp;', '&')
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
