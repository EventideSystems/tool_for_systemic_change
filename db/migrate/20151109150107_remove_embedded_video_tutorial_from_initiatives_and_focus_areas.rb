class RemoveEmbeddedVideoTutorialFromInitiativesAndFocusAreas < ActiveRecord::Migration
  def up
    remove_column :focus_areas, :video_tutorial_embedded_iframe
    remove_column :characteristics, :video_tutorial_embedded_iframe
  end

  def down
    add_column :focus_areas, :video_tutorial_embedded_iframe, :text
    add_column :characteristics, :video_tutorial_embedded_iframe, :text
  end

end
