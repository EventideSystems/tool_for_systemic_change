# == Schema Information
#
# Table name: scorecards
#
#  id                         :integer          not null, primary key
#  deleted_at                 :datetime
#  description                :string
#  name                       :string
#  share_ecosystem_map        :boolean          default(TRUE)
#  share_thematic_network_map :boolean          default(TRUE)
#  type                       :string           default("TransitionCard")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  account_id                 :integer
#  community_id               :integer
#  linked_scorecard_id        :integer
#  shared_link_id             :string
#  wicked_problem_id          :integer
#
# Indexes
#
#  index_scorecards_on_account_id  (account_id)
#  index_scorecards_on_deleted_at  (deleted_at)
#  index_scorecards_on_type        (type)
#
class SustainableDevelopmentGoalAlignmentCard < Scorecard

end
