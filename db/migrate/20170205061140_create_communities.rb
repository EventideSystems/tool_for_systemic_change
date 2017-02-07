class CreateCommunities < ActiveRecord::Migration[5.0]
  def change
    create_table :communities do |t|
      t.string   :name
      t.string   :description
      t.integer  :client_id
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :communities, [:client_id]
    add_index :communities, [:deleted_at]
  end
end
