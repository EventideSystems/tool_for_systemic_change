# frozen_string_literal: true

# == Schema Information
#
# Table name: scorecards
#
#  id                         :integer          not null, primary key
#  deleted_at                 :datetime
#  deprecated_type            :string           default("TransitionCard")
#  description                :string
#  name                       :string
#  share_ecosystem_map        :boolean          default(TRUE)
#  share_thematic_network_map :boolean          default(TRUE)
#  stakeholder_network_cache  :jsonb            not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  community_id               :integer
#  data_model_id              :bigint
#  linked_scorecard_id        :integer
#  shared_link_id             :string
#  wicked_problem_id          :integer
#  workspace_id               :integer
#
# Indexes
#
#  index_scorecards_on_data_model_id    (data_model_id)
#  index_scorecards_on_deleted_at       (deleted_at)
#  index_scorecards_on_deprecated_type  (deprecated_type)
#  index_scorecards_on_workspace_id     (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_model_id => data_models.id)
#
FactoryBot.define do
  factory :scorecard do
    name { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }
    # workspace
    # wicked_problem
    # community
    # data_model
  end
end
