class AddColorToCharacteristics < ActiveRecord::Migration[8.0]
  def change
    add_column :characteristics, :color, :string
  end
end
