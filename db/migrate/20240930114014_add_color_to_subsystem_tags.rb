class AddColorToSubsystemTags < ActiveRecord::Migration[7.1]
  def change
    add_column :subsystem_tags, :color, :string, null: false, default: '#14b8a6'
  end
end
