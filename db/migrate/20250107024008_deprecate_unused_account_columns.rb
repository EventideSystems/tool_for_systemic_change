class DeprecateUnusedAccountColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :accounts, :welcome_message, :deprecated_welcome_message
    rename_column :accounts, :weblink, :deprecated_weblink
    rename_column :accounts, :allow_sustainable_development_goal_alignment_cards, :deprecated_allow_sustainable_development_goal_alignment_cards
    rename_column :accounts, :allow_transition_cards, :deprecated_allow_transition_cards
    rename_column :accounts, :solution_ecosystem_maps, :deprecated_solution_ecosystem_maps
  end
end
