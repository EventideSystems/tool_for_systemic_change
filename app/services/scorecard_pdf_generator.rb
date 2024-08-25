# frozen_string_literal: true

# require 'prawn/scorecards_helper'

# rubocop:disable Metrics/ClassLength
class ScorecardPdfGenerator
  def initialize(scorecard:, initiatives:, focus_areas:)
    @scorecard = scorecard
    @initiatives = initiatives.includes(:subsystem_tags)
    @focus_areas = focus_areas
  end

  def perform
    ::Prawn::Document.extensions << Prawn::ScorecardsHelper

    Prawn::Document.new(page_size: 'A4', page_layout: :landscape, top_margin: 60) do |pdf|
      pdf.page_header(scorecard)
      pdf.font_size 10

      if scorecard.is_a?(SustainableDevelopmentGoalAlignmentCard)
        generate_date_sdgs_card(pdf)
        generate_legend_sdgs_card(pdf)
      else
        generate_data_transition_card(pdf)
        generate_legend_transition_card(pdf)
      end

      generate_initiatives(pdf)
      pdf.page_numbering
    end
  end

  private

  attr_reader :scorecard, :initiatives, :focus_areas

  def generate_date_sdgs_card(pdf)
    initiatives.each_slice(18) do |grouped_initiatives|
      [
        focus_areas[0..2],
        focus_areas[3..6],
        focus_areas[7..9],
        focus_areas[10..13],
        focus_areas[14..15],
        focus_areas[16..16]
      ].each do |grouped_focus_areas|
        pdf.table(
          [
            pdf.focus_areas_header_sdgs_card(grouped_focus_areas),
            pdf.spacer_sdgs_card(grouped_focus_areas)
          ] +
            pdf.data_sdg_card(grouped_initiatives, grouped_focus_areas)
        )

        if initiatives.count > 7
          pdf.start_new_page
        else
          pdf.move_down 50
        end
      end
    end

    pdf.start_new_page if initiatives.count <= 7
  end

  def generate_data_transition_card(pdf)
    initiatives.each_slice(18) do |grouped_initiatives|
      [focus_areas[0..3], focus_areas[4..8]].each do |grouped_focus_areas|
        pdf.table(
          [
            pdf.focus_areas_header_transition_card(grouped_focus_areas),
            pdf.spacer_transition_card(grouped_focus_areas)
          ] +
            pdf.data_transition_card(grouped_initiatives, grouped_focus_areas) +
            [pdf.legend_keys_transition_card(grouped_focus_areas)]
        )

        if initiatives.count > 7
          pdf.start_new_page
        else
          pdf.move_down 50
        end
      end
    end

    pdf.start_new_page if initiatives.count <= 7
  end

  def generate_legend_sdgs_card(pdf)
    pdf.text 'Legend', size: 16

    pdf.stroke do
      pdf.stroke_color 'F8F8F8'
      pdf.stroke_horizontal_rule
      pdf.move_down 15
    end

    pdf.define_grid(columns: 1, rows: 1)

    pdf.grid(0, 0).bounding_box do
      pdf.legend_sdg_card(focus_areas[0..16])
    end

    pdf.start_new_page
  end

  def generate_legend_transition_card(pdf)
    pdf.text 'Legend', size: 16

    pdf.stroke do
      pdf.stroke_color 'F8F8F8'
      pdf.stroke_horizontal_rule
      pdf.move_down 15
    end

    pdf.define_grid(columns: 2, rows: 1)

    pdf.grid(0, 0).bounding_box do
      pdf.legend_transition_card(focus_areas[0..3])
    end

    pdf.grid(0, 1).bounding_box do
      pdf.legend_transition_card(focus_areas[4..8])
    end

    pdf.start_new_page
  end

  def generate_initiatives(pdf)
    pdf.text 'Initiatives', size: 16

    pdf.stroke do
      pdf.stroke_color 'F8F8F8'
      pdf.stroke_horizontal_rule
      pdf.move_down 15
    end

    pdf.column_box([0, pdf.cursor], columns: 2, width: pdf.bounds.width, reflow_margins: true) do
      initiatives.each do |initiative|
        pdf.text "Name: #{pdf.pdf_safe(initiative.name)}", size: 12
        pdf.formatted_text [{ text: 'Started At: ' }, pdf.formatted_date(initiative.started_at)]
        pdf.formatted_text [{ text: 'Finished At: ' }, pdf.formatted_date(initiative.finished_at)]
        pdf.formatted_text [{ text: 'Description: ' }, pdf.formatted_description(initiative.description)]

        if initiative.subsystem_tags.any?
          pdf.text 'Subsystems:', size: 10
          initiative.subsystem_tags.each do |subsystem|
            pdf.text "\t\u2022 #{subsystem.name}", indent_paragraphs: 10
          end
        end
        pdf.move_down 20
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
