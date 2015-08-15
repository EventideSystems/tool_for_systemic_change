class CreateSectors < ActiveRecord::Migration
  def change
    create_table :sectors do |t|
      t.string :name
      t.string :description
      t.timestamps null: false
    end
    add_index :sectors, :name, unique: true
  end
end
