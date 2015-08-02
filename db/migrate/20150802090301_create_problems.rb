class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :name
      t.string :description
      t.references :community
      t.timestamps null: false
    end
  end
end
