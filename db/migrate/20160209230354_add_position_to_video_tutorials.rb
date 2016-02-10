class AddPositionToVideoTutorials < ActiveRecord::Migration
  def change
    add_column :video_tutorials, :position, :integer
  end
end
