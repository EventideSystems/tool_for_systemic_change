# frozen_string_literal: true

module Accounts
  class Copy
    attr_reader :account, :new_name

    def self.call(account:, new_name: nil)
      new(account:, new_name:).call
    end

    def initialize(account:, new_name: nil)
      @account = account
      @new_name = new_name.presence || "#{account.name} (copy)"
    end

    def call
      account.dup.tap do |new_account|
        new_account.name = new_name
        new_account.save!

        # For now, remove stakeholder types and focus area groups created by the Account#setup_account method
        new_account.reload
        new_account.stakeholder_types.delete_all
        new_account.focus_area_groups.delete_all

        copy_stakeholder_types(new_account)
        copy_focus_area_groups(new_account)
      end
    end

    private

    def copy_stakeholder_types(new_account)
      account.stakeholder_types.each do |stakeholder_type|
        new_stakeholder_type = stakeholder_type.dup
        new_stakeholder_type.account = new_account
        new_stakeholder_type.save!
      end
    end

    def copy_focus_area_groups(new_account)
      FocusAreaGroup.where(account:).find_each do |focus_area_group|
        new_focus_area_group = create_focus_area_group(focus_area_group, new_account)

        focus_area_group.focus_areas.each do |focus_area|
          new_focus_area = create_focus_area(new_focus_area_group, focus_area)

          focus_area.characteristics.each do |characteristic|
            create_characteristic(new_focus_area, characteristic)
          end

          new_focus_area_group.save!
        end
      end
    end

    def create_focus_area_group(focus_area_group, new_account)
      FocusAreaGroup.create!(
        focus_area_group
          .attributes.except('id', 'created_at', 'updated_at')
          .merge(account_id: new_account.id)
      )
    end

    def create_focus_area(new_focus_area_group, focus_area)
      new_focus_area_group.focus_areas.build(
        focus_area.attributes.except('id', 'focus_area_group_id', 'created_at', 'updated_at')
      )
    end

    def create_characteristic(new_focus_area, characteristic)
      new_focus_area.characteristics.build(
        characteristic.attributes.except('id', 'focus_area_id', 'created_at', 'updated_at')
      )
    end
  end
end
