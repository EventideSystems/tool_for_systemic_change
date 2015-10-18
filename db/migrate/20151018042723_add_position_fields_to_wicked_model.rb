class AddPositionFieldsToWickedModel < ActiveRecord::Migration

  class FocusAreaGroup < ActiveRecord::Base; end
  class FocusArea < ActiveRecord::Base; end
  class Characteristic < ActiveRecord::Base; end

  def up
    add_column :focus_area_groups, :position, :integer
    add_column :focus_areas, :position, :integer
    add_column :characteristics, :position, :integer

    focus_area_group_position = 0
    FocusAreaGroup.all.each do |focus_area_group|
      focus_area_group_position += 1
      focus_area_group.position = focus_area_group_position
      focus_area_group.save!


      focus_area_position = 0
      FocusArea.where(focus_area_group_id: focus_area_group.id).each do |focus_area|
        focus_area_position += 1
        focus_area.position = focus_area_position
        focus_area.save!

        characteristic_position = 0
        Characteristic.where(focus_area_id: focus_area.id).each do |characteristic|
          characteristic_position += 1
          characteristic.position = characteristic_position
          characteristic.save!
        end
      end

    end
  end

  def down
    remove_column :focus_area_groups, :position, :integer
    remove_column :focus_areas, :position, :integer
    remove_column :characteristics, :position, :integer
  end
end
