# frozen_string_literal: true

require 'csv'

module Reports
  class TransitionCardStakeholders < Base
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
          sheet.add_row([DateTime.now], style: styles[:date])
          add_title(sheet, styles)
          sheet.add_row
          add_summary(sheet, styles)
          sheet.add_row
          add_unique_organisations(sheet, styles)
          sheet.add_row
          add_initiatives(sheet, styles)
          sheet.add_row
          add_stakeholder_types(sheet, styles)
        end
      end.to_stream
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def add_summary(sheet, styles)
      sheet.add_row(['Total Partnering Organisations', total_partnering_organisations], style: styles[:h1])
      sheet.add_row(["Total #{scorecard.model_name.human} Initiatives", total_transition_card_initiatives],
                        style: styles[:h1])
    end

    def add_initiatives(sheet, styles)
      sheet.add_row(['Initiatives', 'Total Organisations', 'Organisations'], style: styles[:h3])
      scorecard.initiatives.not_archived.each do |initiative|
        name = initiative.name
        organisations = organisations_for_initiative(initiative)
        organisations_names = organisations.map(&:name)
        total_organisations = organisations.count

        sheet.add_row([name, total_organisations] + organisations_names)
      end
    end

    def add_stakeholder_types(sheet, styles)
      sheet.add_row(['Stakeholder Type', 'Total Organisations', 'Organisations'], style: styles[:h3])
      StakeholderType.where(account: scorecard.account).order(:name).each do |stakeholder_type|
        name = stakeholder_type.name
        organisations = organisations_for_stakeholder_type(stakeholder_type)
        organisations_names = organisations.map(&:name)
        total_organisations = organisations.count

        sheet.add_row([name, total_organisations] + organisations_names)
      end
    end

    def add_title(sheet, styles)
      sheet.add_row([scorecard.model_name.human], style: styles[:h1]).add_cell(scorecard.name, style: styles[:blue_normal])
      sheet.add_row(['Wicked problem / opportunity', scorecard.wicked_problem.name])
      sheet.add_row(['Community', scorecard.community&.name || 'MISSING DATA'])
    end

    def add_unique_organisations(sheet, styles)
      sheet.add_row(['Organisations', 'Total Initiatives', 'Stakeholder Type', 'Initiatives'], style: styles[:h3])
      scorecard.unique_organisations.each do |organisation|
        name = organisation.name
        initiatives = initiatives_for_organisation(organisation)
        initiatives_names = initiatives.map(&:name)
        total_initiatives = initiatives.count
        stakeholder_type = organisation.stakeholder_type&.name || ''

        sheet.add_row([name, total_initiatives, stakeholder_type] + initiatives_names)
      end
    end

    def total_partnering_organisations
      scorecard.unique_organisations.count
    end

    def total_transition_card_initiatives
      scorecard.initiatives.not_archived.count
    end

    def initiatives_for_organisation(organisation)
      initiative_ids = scorecard
                       .initiatives_organisations
                       .where(organisation_id: organisation.id)
                       .pluck(:initiative_id)
                       .uniq

      scorecard.initiatives.not_archived.where(id: initiative_ids)
    end

    def organisations_for_initiative(initiative)
      organisation_ids = scorecard
                         .initiatives_organisations
                         .where(initiative_id: initiative.id)
                         .pluck(:organisation_id)
                         .uniq

      Organisation.where(id: organisation_ids).order('lower(organisations.name)')
    end

    def organisations_for_stakeholder_type(stakeholder_type)
      scorecard.unique_organisations.select { |organisation| organisation.stakeholder_type == stakeholder_type }
    end
  end
end
