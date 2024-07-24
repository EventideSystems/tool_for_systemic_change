# frozen_string_literal: true

class DuplicateFocusAreaGroupsPerAccount < ActiveRecord::Migration[7.0]
  def up
    focus_area_groups = FocusAreaGroup.where(account: nil).includes(focus_areas: :characteristics)

    Account.with_deleted.ids.each do |account_id|
      focus_area_groups.each do |focus_area_group|
        new_focus_area_group = \
          FocusAreaGroup
            .create(
              focus_area_group
                .attributes.except('id', 'created_at', 'updated_at')
                .merge('account_id' => account_id)
              )

        focus_area_group.focus_areas.each do |focus_area|
          new_focus_area = \
            new_focus_area_group
              .focus_areas
              .build(focus_area.attributes.except('id', 'focus_area_group_id', 'created_at', 'updated_at'))

          focus_area.characteristics.each do |characteristic|
            new_characteristic = \
              new_focus_area
                .characteristics
                .build(characteristic.attributes.except('id', 'focus_area_id', 'created_at', 'updated_at'))
          end

          new_focus_area_group.save!
        end
      end
    end
  end

  def down
    FocusAreaGroup.where.not(account_id: nil).find_each do |focus_area_group|
      focus_area_group.focus_areas.each do |focus_area|
        focus_area.characteristics.each(&:delete)
        focus_area.delete
      end
      focus_area_group.delete
    end
  end
end
