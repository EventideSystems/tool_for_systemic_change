# frozen_string_literal: true

module Initiatives
  class Import < Import
    MAX_ORGANIZATION_EXPORT = 15
    MAX_SUBSYSTEM_TAG_EXPORT = 15

    def process(account)
      name_index             = column_index(:name)
      description_index      = column_index(:description)
      scorecard_name_index   = column_index_for_scorecard_name
      started_at_index       = column_index(:started_at)
      finished_at_index      = column_index(:finished_at)
      contact_name_index     = column_index(:contact_name)
      contact_email_index    = column_index(:contact_email)
      contact_phone_index    = column_index(:contact_phone)
      contact_website_index  = column_index(:contact_website)
      contact_position_index = column_index(:contact_position)

      data_rows.each.with_index(1) do |raw_row, row_index|
        row = sanitize_row(raw_row)

        if name_index.nil?
          processing_errors << build_processing_errors(
            row_data: row, row_index: row_index, error_messages: ["'Name' column is missing"]
          )
          next
        end

        if scorecard_name_index.nil?
          processing_errors << build_processing_errors(
            row_data: row,
            row_index: row_index,
            error_messages: ["Scorecard name column is missing. Please add a column named 'Scorecard Name' or 'Transition Card Name'"]
          )
          next
        end

        scorecard = find_scorecard_by_name(account, row[scorecard_name_index])

        if scorecard.nil?
          processing_errors << build_processing_errors(
            row_data: row, row_index: row_index, error_messages: ["#{Scorecard.model_name.human} cannot be found"]
          )
          next
        end

        initiative = find_or_build_initiative_by_name(scorecard, row[name_index])

        unknown_organisation_names = []

        1.upto(MAX_ORGANIZATION_EXPORT).each do |org_index|
          organisation_name_index = header_row.index { |i| i&.downcase == "organisation #{org_index} name" }
          organisation_name = row[organisation_name_index]

          next if organisation_name.blank?

          organisation = find_organisation_by_name(account, organisation_name)

          if organisation
            initiative.organisations << organisation unless initiative.organisations.include?(organisation)
          else
            unknown_organisation_names << organisation_name
          end
        end

        unknown_subsystem_tag_names = []

        1.upto(MAX_SUBSYSTEM_TAG_EXPORT).each do |subsystem_tag_index|
          subsystem_tag_name_index = header_row.index { |i| i&.downcase == "subsystem tag #{subsystem_tag_index} name" }
          subsystem_tag_name = subsystem_tag_name_index.present? ? row[subsystem_tag_name_index] : nil

          next if subsystem_tag_name.blank?

          subsystem_tag = find_subsystem_tag_by_name(account, subsystem_tag_name)

          subsystem_tag = SubsystemTag.create!(account: account, name: subsystem_tag_name) if subsystem_tag.blank?

          initiative.subsystem_tags << subsystem_tag unless initiative.subsystem_tags.include?(subsystem_tag)
        end

        success = initiative.update(
          {}.tap do |attributes|
            attributes[:name]             = row[name_index]
            attributes[:description]      = row[description_index] if row[description_index].present?
            attributes[:scorecard]        = scorecard
            attributes[:started_at]       = sanitized_date(row[started_at_index])  if row[started_at_index].present?
            attributes[:finished_at]      = sanitized_date(row[finished_at_index]) if row[finished_at_index].present?
            attributes[:contact_name]     = row[contact_name_index]                if row[contact_name_index].present?
            attributes[:contact_email]    = row[contact_email_index]               if row[contact_email_index].present?
            attributes[:contact_phone]    = row[contact_phone_index]               if row[contact_phone_index].present?
            if row[contact_website_index].present?
              attributes[:contact_website]  =
                row[contact_website_index]
            end
            if row[contact_position_index].present?
              attributes[:contact_position] =
                row[contact_position_index]
            end
          end
        )

        success = success && unknown_organisation_names.empty? && unknown_subsystem_tag_names.empty?

        unless success
          error_messages = initiative.errors.full_messages || []
          unless unknown_organisation_names.empty?
            error_messages << "Unknown Organisation Names: #{unknown_organisation_names.join(', ')}."
          end
          unless unknown_subsystem_tag_names.empty?
            error_messages << "Unknown Subsystem Tag Names: #{unknown_subsystem_tag_names.join(', ')}."
          end
          processing_errors << build_processing_errors(
            row_data: row, row_index: row_index, error_messages: error_messages
          )
        end
      end

      processing_errors.empty?
    end

    private

    def column_index_for_scorecard_name
      candidate_column_names = %w[scorecard_name transition_card_name sdg_card_name]
      header_row.index { |i| i&.downcase.gsub(/\s/, '_').in? candidate_column_names }
    end

    def find_scorecard_by_name(account, name)
      account.scorecards.where('lower(name) = :name', { name: name.downcase }).first
    end

    def find_organisation_by_name(account, name)
      account.organisations.where('lower(name) = :name', { name: name.downcase }).first
    end

    def find_subsystem_tag_by_name(account, name)
      account.subsystem_tags.where('lower(name) = :name', { name: name.downcase }).first
    end

    def find_or_build_initiative_by_name(scorecard, name)
      initiative = scorecard.initiatives.where(
        'lower(name) = :name ', { name: name.downcase }
      ).first

      initiative || scorecard.initiatives.create
    end
  end
end
