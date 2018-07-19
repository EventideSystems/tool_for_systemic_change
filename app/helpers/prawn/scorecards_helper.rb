require "prawn"
require "prawn/table"

module Prawn
  module ScorecardsHelper
    include ::ActionView::Helpers::TextHelper

    def focus_area_color(focus_area)
      %w(FD6E77 FADD83 FEA785 AFBFF5 84ACD4 74C4DF 71B9B9 7AE0CC 7FD4A0)[focus_area.position-1]
    end
  
    def page_header(scorecard)
      img = File.join(Rails.root, 'app/assets/images/logo-long-white-bg.png')
    
      repeat(:all) do
        canvas do 
          bounding_box [bounds.left + 30, bounds.top - 20], width: bounds.width - 60 do
            font_size 22
            pad_top(8) { text "Transition Card: #{truncate(scorecard.name, length: 40)}", :valign => :top }
            image img, :position => :right, :width => 130, :vposition => :top
          end
        end
      end
    end
  
    def header(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, index|
        { content: "Focus Area #{focus_area.position}", 
          colspan: focus_area.characteristics.count,
          text_color: focus_area_color(focus_area),
          align: :center,
          border_width: 0 
        }
      end
    end
  
    def spacer(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, index|
        { content: "", 
          colspan: focus_area.characteristics.count,
          borders: [:top, :left, :right],
          border_lines: [:dotted],
          border_color: focus_area_color(focus_area),
          border_width: 1 
        }
      end
    end
  
    def legend_keys(focus_areas)
        [{ content: '', border_width: 0 }] + focus_areas.inject([]) do |memo, focus_area|
    
        focus_area.characteristics.inject(memo) do |memo, characteristic|
          memo.push({ 
            content: characteristic.identifier, 
            text_color: focus_area_color(focus_area),
            border_width: 0,
            align: :center,
            size: 8
          })
          memo
        end
    
        memo
      end
    end
  
    def legend(focus_areas)
      move_down 30
      focus_areas.each_with_index do |focus_area, focus_area_index|
        move_down 5
        formatted_text [
          { text: "Focus Area #{focus_area.position}", styles: [:bold], color: focus_area_color(focus_area) },
          { text: " - #{focus_area.name.force_encoding("UTF-8")}", size: 10 }
        ], leading: 6
        focus_area.characteristics.each_with_index do |characteristic, characteristic_index|
          formatted_text [ 
            { text: characteristic.identifier, color: focus_area_color(focus_area) }, 
            { text: " - #{characteristic.name.force_encoding("UTF-8")}" }
          ], indent_paragraphs: 10, size: 8, leading: 4
        end
      end
    end
  
    def data(initiatives, focus_areas)
      initiatives.map do |initiative|
        [{ content: truncate(pdf_safe(initiative.name), length: 62, escape: false), text_color: '3C8DBC', border_width: 0, width: 300 }] + initiative.checklist_items_ordered_by_ordered_focus_area(focus_areas: focus_areas).map do |checklist_item|
          { content: " ", border_width: 2, border_color: 'FFFFFF' }.tap do |cell|
            cell[:background_color] = checklist_item.checked? ? focus_area_color(checklist_item.focus_area) : 'F8F8F8'
          end
        end
      end
    end

    def page_numbering
      font_size 12
      string = "Page <page> of <total>"
      options = { 
        :at => [bounds.right - 150, 0],
        :width => 150,
        :align => :right,
        :start_count_at => 1
      }
      number_pages string, options
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
        { text: description }
      else
        { text: 'No description', styles: [:italic] }
      end
    end
  
    def pdf_safe(text)
      ActionView::Base.full_sanitizer.sanitize(text.force_encoding("UTF-8"), tags: []).gsub(/&amp;/, '&') 
    end
  end
end

