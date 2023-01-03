# frozen_string_literal: true

class CreateSectorsForAccounts < ActiveRecord::Migration[7.0]
  class StakeholderType < ApplicationRecord
    belongs_to :account, optional: true
    scope :system_stakeholder_types, -> { where(account_id: nil) }
  end

  def up
    templates = StakeholderType.system_stakeholder_types

    Account.all.each do |account|
      templates.each do |template|
        stakeholder_type = template.dup.tap { |s| s.account = account }
        stakeholder_type.save!

        Organisation.where(account: account, stakeholder_type: template).update_all(stakeholder_type_id: stakeholder_type.id)
      end
    end
  end

  def down
    Account.all.each do |account|
      account.stakeholder_types.each do |stakeholder_type|
        template = StakeholderType.system_stakeholder_types.find_by(name: stakeholder_type.name)

        next if template.nil?

        Organisation.where(account: account, stakeholder_type: stakeholder_type).update_all(stakeholder_type_id: template.id)
      end
    end

    StakeholderType.where.not(account_id: nil).delete_all
  end

end
