class AddNameIndexToIntitiatives < ActiveRecord::Migration[5.0]
  def change
    add_index :initiatives, [:name]
  end
end
