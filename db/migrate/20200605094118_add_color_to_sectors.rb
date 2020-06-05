class AddColorToSectors < ActiveRecord::Migration[5.0]
  def change
    add_column :sectors, :color, :string
  end
end
