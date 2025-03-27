# frozen_string_literal: true

# == Schema Information
#
# Table name: focus_area_groups
#
#  id                        :integer          not null, primary key
#  deleted_at                :datetime
#  description               :string
#  name                      :string
#  position                  :integer
#  scorecard_type            :string           default("TransitionCard")
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  impact_card_data_model_id :bigint
#  workspace_id              :bigint
#
# Indexes
#
#  index_focus_area_groups_on_deleted_at                 (deleted_at)
#  index_focus_area_groups_on_impact_card_data_model_id  (impact_card_data_model_id)
#  index_focus_area_groups_on_position                   (position)
#  index_focus_area_groups_on_scorecard_type             (scorecard_type)
#  index_focus_area_groups_on_workspace_id               (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (impact_card_data_model_id => impact_card_data_models.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  sequence(:focus_area_group_position) { |n| n }

  factory :focus_area_group do
    name { FFaker::Name.name }
    position { generate(:focus_area_group_position) }
  end
end
