# frozen_string_literal: true

# == Schema Information
#
# Table name: focus_area_groups
#
#  id                        :integer          not null, primary key
#  code                      :string
#  color                     :string
#  deleted_at                :datetime
#  deprecated_scorecard_type :string           default("TransitionCard")
#  description               :string
#  name                      :string
#  position                  :integer
#  short_name                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deprecated_workspace_id   :bigint
#  impact_card_data_model_id :bigint
#
# Indexes
#
#  index_focus_area_groups_on_deleted_at                          (deleted_at)
#  index_focus_area_groups_on_deprecated_scorecard_type           (deprecated_scorecard_type)
#  index_focus_area_groups_on_deprecated_workspace_id             (deprecated_workspace_id)
#  index_focus_area_groups_on_impact_card_data_model_id           (impact_card_data_model_id)
#  index_focus_area_groups_on_impact_card_data_model_id_and_code  (impact_card_data_model_id,code) UNIQUE
#  index_focus_area_groups_on_position                            (position)
#
# Foreign Keys
#
#  fk_rails_...  (deprecated_workspace_id => workspaces.id)
#  fk_rails_...  (impact_card_data_model_id => impact_card_data_models.id)
#
FactoryBot.define do
  sequence(:focus_area_group_position) { |n| n }

  factory :focus_area_group do
    name { FFaker::Name.name }
    position { generate(:focus_area_group_position) }
  end
end
