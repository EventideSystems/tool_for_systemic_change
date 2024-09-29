class AddColorToWickedProblems < ActiveRecord::Migration[7.1]
  def change
    add_column :wicked_problems, :color, :string, null: false, default: '#14b8a6'
  end
end
