# frozen_string_literal: true

# == Schema Information
#
# Table name: focus_area_groups
#
#  id             :integer          not null, primary key
#  deleted_at     :datetime
#  description    :string
#  name           :string
#  position       :integer
#  scorecard_type :string           default("TransitionCard")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  workspace_id   :bigint
#
# Indexes
#
#  index_focus_area_groups_on_deleted_at      (deleted_at)
#  index_focus_area_groups_on_position        (position)
#  index_focus_area_groups_on_scorecard_type  (scorecard_type)
#  index_focus_area_groups_on_workspace_id    (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_id => workspaces.id)
#
class FocusAreaGroup < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:position) }

  belongs_to :workspace, optional: true

  has_many :focus_areas, dependent: :restrict_with_error

  validates :position, presence: true
end
