# frozen_string_literal: true

require 'csv'

module Reports
  class SubsystemSummary < Base
    attr_accessor :scorecard

    def initialize(scorecard)
      super()
      @scorecard = scorecard
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def to_xlsx
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'
        styles = default_styles(p)
        p.workbook.add_worksheet(name: 'Report') do |sheet|
          sheet.add_row([Time.zone.now], style: styles[:date])
          add_title(sheet, styles)
          sheet.add_row
          add_summary(sheet, styles)
          sheet.add_row
          add_initiatives_per_subsystem(sheet, styles)
          sheet.add_row
          add_organisations_per_subsystem(sheet, styles)
        end
      end.to_stream
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def scorecard_model_name
      case scorecard
      when TransitionCard
        scorecard.account.transition_card_model_name
      when SustainableDevelopmentGoalAlignmentCard
        scorecard.account.sdgs_alignment_card_model_name
      end
    end

    def add_title(sheet, styles)
      sheet.add_row([scorecard_model_name], style: styles[:h1]).add_cell(scorecard.name, style: styles[:blue_normal])
      sheet.add_row(['Wicked problem / opportunity', scorecard.wicked_problem.name])
      sheet.add_row(['Community', scorecard.community&.name || 'MISSING DATA'])
    end

    def add_summary(sheet, styles)
      sheet.add_row(['Total Subsystems', total_subsystems], style: styles[:h1])
      sheet.add_row(['Total Partnering Organisations', total_partnering_organisations], style: styles[:h1])
      sheet.add_row(
        ["Total #{scorecard_model_name} Initiatives", total_transition_card_initiatives],
        style: styles[:h1]
      )
    end

    def add_initiatives_per_subsystem(sheet, styles)
      initiatives_per_subsystem = fetch_initiatives_per_subsystem
      max_initiatives = initiatives_per_subsystem.values.map(&:count).max || 0

      sheet.add_row(['Subsystem ', 'Total Initiatives'] + Array.new(max_initiatives, 'Initiatives'), style: styles[:h3])
      initiatives_per_subsystem.each do |subsystem, initiatives|
        sheet.add_row([subsystem, initiatives.count] + initiatives)
      end
    end

    def add_organisations_per_subsystem(sheet, styles)
      organisations_per_subsystem = fetch_organisations_per_subsystem
      max_organisations = organisations_per_subsystem.values.map(&:count).max || 0

      sheet.add_row(
        ['Subsystem ', 'Total Organisations'] + Array.new(max_organisations, 'Organisations'),
        style: styles[:h3]
      )
      organisations_per_subsystem.each do |subsystem, organisations|
        sheet.add_row([subsystem, organisations.count] + organisations)
      end
    end

    def total_partnering_organisations
      scorecard.unique_organisations.count
    end

    def total_transition_card_initiatives
      scorecard.initiatives.not_archived.count
    end

    # NOTE: Not sure what Emily requires here. The following code restricts the
    #       number of partnering organisations and initiatives to those that are
    #       part of the subsystems.
    #       The code above is the same as the code in Reports::TransitionCardStakeholders
    #
    # def total_partnering_organisations
    #   subsystem_tags_query.flat_map(&:initiatives).flat_map(&:organisations).uniq.count
    # end

    # def total_transition_card_initiatives
    #   subsystem_tags_query.flat_map(&:initiatives).uniq.count
    # end

    def total_subsystems
      subsystem_tags_query.uniq.count
    end

    def fetch_initiatives_per_subsystem
      subsystem_tags_query.each_with_object({}) do |subsystem, memo|
        memo[subsystem.name] = subsystem.initiatives.map(&:name).uniq.sort
      end
    end

    def fetch_organisations_per_subsystem
      subsystem_tags_query.each_with_object({}) do |subsystem, memo|
        memo[subsystem.name] = subsystem.initiatives.flat_map(&:organisations).flat_map(&:name).uniq.sort
      end
    end

    def subsystem_tags_query
      SubsystemTag
        .joins(:initiatives)
        .includes(:initiatives)
        .where('initiatives.archived_on is null or initiatives.archived_on > ?', Time.zone.now)
        .where('initiatives.scorecard_id': scorecard.id).distinct
        .order(:name)
    end
  end
end
