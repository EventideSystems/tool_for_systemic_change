class AddColorToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :communities, :color, :string, null: false, default: '#14b8a6'
  end
end
