class AddClientIdIndexToWickedProblems < ActiveRecord::Migration
  def change
    add_index :wicked_problems, :client_id
  end
end
