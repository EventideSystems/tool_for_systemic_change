class CreateVideoTutorials < ActiveRecord::Migration[5.0]
  def change
    create_table :video_tutorials do |t|
      t.integer  :linked_id
      t.string   :linked_type
      t.string   :link_url
      t.string   :name
      t.text     :description
      t.boolean  :promote_to_dashboard
      t.integer  :position
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :video_tutorials, [:deleted_at]
    add_index :video_tutorials, [:linked_type, :linked_id]
  end
end
