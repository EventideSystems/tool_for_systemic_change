class AddEmbeddedVideoTutorialToInitiativesAndFocusAreas < ActiveRecord::Migration
  def change
    add_column :focus_areas, :video_tutorial_embedded_iframe, :text
    add_column :characteristics, :video_tutorial_embedded_iframe, :text
  end
end
