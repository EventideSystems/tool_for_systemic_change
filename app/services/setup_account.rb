# frozen_string_literal: true

# Set up new account
class SetupAccount

  attr_reader :account

  def self.call(account:)
    new(account:).call
  end

  def initialize(account:)
    @account = account
  end

  def call
    create_stakeholder_types
    create_focus_area_groups
  end

  private

  def create_stakeholder_types
    StakeholderType.system_stakeholder_types.each do |template|
      template
        .dup
        .tap { |s| s.account = account }
        .save!
    end
  end

  def create_focus_area_groups
    FocusAreaGroup.where(account: nil).find_each do |focus_area_group|
      new_focus_area_group = \
        FocusAreaGroup
        .create(
          focus_area_group
            .attributes.except('id', 'created_at', 'updated_at')
            .merge('account_id' => account.id)
        )

      focus_area_group.focus_areas.each do |focus_area|
        new_focus_area = \
          new_focus_area_group
          .focus_areas
          .build(focus_area.attributes.except('id', 'focus_area_group_id', 'created_at', 'updated_at'))

        focus_area.characteristics.each do |characteristic|
          new_focus_area
            .characteristics
            .build(characteristic.attributes.except('id', 'focus_area_id', 'created_at', 'updated_at'))
        end

        new_focus_area_group.save!
      end
    end
  end
end
