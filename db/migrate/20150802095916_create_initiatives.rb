class CreateInitiatives < ActiveRecord::Migration
  def change
    create_table :initiatives do |t|
      t.string :name
      t.string :description
      t.references :problem
      t.timestamps null: false
    end
  end
end
