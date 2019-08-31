class AddNotesToIntiatives < ActiveRecord::Migration[5.0]
  def change
    add_column :initiatives, :notes, :text
  end
end
