# frozen_string_literal: true

require 'csv'

module Reports
  class TransitionCardStakeholders
    attr_accessor :scorecard

    def initialize(scorecard)
      @scorecard = scorecard
    end

    def to_xlsx
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'

        header_1 = p.workbook.styles.add_style fg_color: '386190', sz: 16, b: true
        header_2 = p.workbook.styles.add_style bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: true
        header_3 = p.workbook.styles.add_style bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: false
        blue_normal = p.workbook.styles.add_style fg_color: '386190', sz: 12, b: false
        wrap_text = p.workbook.styles.add_style alignment: { horizontal: :general, vertical: :bottom, wrap_text: true }
        date = p.workbook.styles.add_style format_code: 'd/m/yy'

        p.workbook.add_worksheet(name: 'Report') do |sheet|
          sheet.add_row([scorecard.model_name.human], style: header_1).add_cell(scorecard.name, style: blue_normal)
          sheet.add_row(['Wicked problem / opportunity', scorecard.wicked_problem.name])
          sheet.add_row(['Community', scorecard.community.name])
          sheet.add_row(['Date generated']).add_cell(Date.today, style: date)

          sheet.add_row

          sheet.add_row(['Total Partnering Organisations', total_partnering_organisations], style: header_1)
          sheet.add_row(["Total #{scorecard.model_name.human} Initiatives", total_transition_card_initiatives],
                        style: header_1)

          sheet.add_row

          sheet.add_row(['Organisations', 'Total Initiatives', 'Sector', 'Initiatives'], style: header_3)
          scorecard.unique_organisations.each do |organisation|
            name = organisation.name
            initiatives = initiatives_for_organisation(organisation)
            initiatives_names = initiatives.map(&:name)
            total_initiatives = initiatives.count
            sector = organisation.sector&.name || ''

            sheet.add_row([name, total_initiatives, sector] + initiatives_names)
          end

          sheet.add_row

          sheet.add_row(['Initiatives', 'Total Organisations', 'Organisations'], style: header_3)
          scorecard.initiatives.each do |initiative|
            name = initiative.name
            organisations = organisations_for_initiative(initiative)
            organisations_names = organisations.map(&:name)
            total_organisations = organisations.count

            sheet.add_row([name, total_organisations] + organisations_names)
          end

          sheet.add_row

          sheet.add_row(['Stakeholder Breakdown', 'Total Organisations', 'Organisations'], style: header_3)
          Sector.all.each do |sector|
            name = sector.name
            organisations = organisations_for_sector(sector)
            organisations_names = organisations.map(&:name)
            total_organisations = organisations.count

            sheet.add_row([name, total_organisations] + organisations_names)
          end
        end
      end.to_stream
    end

    private

    def total_partnering_organisations
      scorecard.unique_organisations.count
    end

    def total_transition_card_initiatives
      scorecard.initiatives.count
    end

    def initiatives_for_organisation(organisation)
      initiative_ids = scorecard
                       .initiatives_organisations
                       .where(organisation_id: organisation.id)
                       .pluck(:initiative_id)
                       .uniq
      scorecard.initiatives.where(id: initiative_ids)
    end

    def organisations_for_initiative(initiative)
      organisation_ids = scorecard
                         .initiatives_organisations
                         .where(initiative_id: initiative.id)
                         .pluck(:organisation_id)
                         .uniq
      Organisation.where(id: organisation_ids).order('lower(organisations.name)')
    end

    def organisations_for_sector(sector)
      scorecard.unique_organisations.select { |organisation| organisation.sector == sector }
    end
  end
end
