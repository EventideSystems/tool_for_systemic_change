class AddDeactivatedToClient < ActiveRecord::Migration
  def change
    add_column :clients, :deactivated, :boolean
  end
end
