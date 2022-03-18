class AddLinkedToInitiatives < ActiveRecord::Migration[6.1]
  def change
    add_column :initiatives, :linked, :boolean, default: false
  end
end
