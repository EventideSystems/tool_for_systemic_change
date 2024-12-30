class DeprecateVideoTutorials < ActiveRecord::Migration[8.0]
  def change
    rename_table :video_tutorials, :deprecated_video_tutorials
  end
end
