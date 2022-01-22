class AddScorecardTypesToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :allow_transition_cards, :bool, default: true
    add_column :accounts, :allow_sustainable_development_goal_alignment_cards, :bool, default: false
  end
end
