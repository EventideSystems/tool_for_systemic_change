class CreateVideoTutorials < ActiveRecord::Migration
  def change
    create_table :video_tutorials do |t|
      t.references :linked, polymorphic: true, index: true
      t.string :link_url
      t.string :name
      t.text :description
      t.boolean :promote_to_dashboard
      t.timestamps null: false
    end
  end
end
