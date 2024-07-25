# frozen_string_literal: true

class AddCustomModelNames < ActiveRecord::Migration[7.0]
  def change
    add_column(:accounts, :transition_card_model_name, :string, default: 'Transition Card')
    add_column(:accounts, :transition_card_focus_area_group_model_name, :string, default: 'Focus Area Group')
    add_column(:accounts, :transition_card_focus_area_model_name, :string, default: 'Focus Area')
    add_column(:accounts, :transition_card_characteristic_model_name, :string, default: 'Characteristic')

    add_column(:accounts, :sdgs_alignment_card_model_name, :string, default: 'SDGs Alignment Card')
    add_column(:accounts, :sdgs_alignment_card_focus_area_group_model_name, :string, default: 'Focus Area Group')
    add_column(:accounts, :sdgs_alignment_card_focus_area_model_name, :string, default: 'Focus Area')
    add_column(:accounts, :sdgs_alignment_card_characteristic_model_name, :string, default: 'Targets')
  end
end
