# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id          :integer          not null, primary key
#  import_data :text
#  status      :integer          default("pending")
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#  user_id     :integer
#
# Indexes
#
#  index_imports_on_account_id  (account_id)
#  index_imports_on_user_id     (user_id)
#
module Organisations
  # Class for importing organisations
  class Import < Import
    def process(account) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      name_index              = column_index(:name)
      description_index       = column_index(:description)
      stakeholder_type_index  = column_index(:stakeholder_type) || column_index(:sector)
      weblink_index           = column_index(:weblink)

      if name_index.nil?
        processing_errors << build_processing_errors(
          row_data: data_rows.first, row_index: 0, error_messages: ["Import file is mising 'name' header on first line"]
        )
        return false
      end

      data_rows.each.with_index(1) do |raw_row, row_index| # rubocop:disable Metrics/BlockLength
        row = sanitize_row(raw_row)

        next if row.compact.empty?

        next if row[name_index].blank?

        organisation = find_or_build_organisation_by_name(account, row[name_index])
        stakeholder_type = if stakeholder_type_index.nil?
                             nil
                           else
                             find_stakeholder_type_by_name(account,
                                                           row[stakeholder_type_index])
                           end

        if stakeholder_type.nil?
          processing_errors << build_processing_errors(
            row_data: row, row_index: row_index, error_messages: ['Stakeholder Type is invalid']
          )
          next
        end

        success = organisation.update(
          {}.tap do |attributes|
            attributes[:name]        = row[name_index]
            attributes[:description] = row[description_index] if description_index && row[description_index].present?
            attributes[:stakeholder_type] = stakeholder_type
            attributes[:weblink] = row[weblink_index] if weblink_index && row[weblink_index].present?
          end
        )

        unless success
          processing_errors << build_processing_errors(
            row_data: row, row_index: row_index, error_messages: organisation.errors.full_messages
          )
        end
      end

      processing_errors.empty?
    end

    private

    def find_stakeholder_type_by_name(account, name)
      return nil if name.nil?

      StakeholderType.where(
        'lower(name) = :name and account_id = :account_id',
        { name: name.downcase.strip, account_id: account.id }
      ).first
    end

    def find_or_build_organisation_by_name(account, name)
      organisation = account.organisations.where(
        'lower(name) = :name', { name: name.downcase }
      ).first

      organisation || account.organisations.build
    end
  end
end
