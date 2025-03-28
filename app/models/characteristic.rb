# frozen_string_literal: true

# == Schema Information
#
# Table name: characteristics
#
#  id            :integer          not null, primary key
#  deleted_at    :datetime
#  description   :string
#  name          :string
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  focus_area_id :integer
#
# Indexes
#
#  index_characteristics_on_deleted_at     (deleted_at)
#  index_characteristics_on_focus_area_id  (focus_area_id)
#  index_characteristics_on_position       (position)
#
class Characteristic < ApplicationRecord
  acts_as_paranoid

  default_scope { order('focus_areas.position', :position).joins(:focus_area) }

  belongs_to :focus_area
  has_many :checklist_items, dependent: :nullify

  # TODO: Add scoped position validation to database schema
  validates :position, presence: true, uniqueness: { scope: :focus_area } # rubocop:disable Rails/UniqueValidationWithoutIndex
  delegate :position, to: :focus_area, prefix: true

  delegate :scorecard_type, :workspace, to: :focus_area

  scope :per_scorecard_type_for_workspace, lambda { |scorecard_type, workspace|
    joins(focus_area: :focus_area_group)
      .where(
        'focus_area_groups_focus_areas.scorecard_type' => scorecard_type,
        'focus_area_groups_focus_areas.workspace_id' => workspace.id
      )
  }

  def identifier
    "#{focus_area.position}.#{position}"
  end

  def short_name
    name.match(/(\d*\.\d*)\s.*/)[1] || name
  end
end
