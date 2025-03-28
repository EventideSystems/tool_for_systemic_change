# frozen_string_literal: true

# == Schema Information
#
# Table name: focus_areas
#
#  id                  :integer          not null, primary key
#  actual_color        :string
#  deleted_at          :datetime
#  description         :string
#  icon_name           :string           default("")
#  name                :string
#  planned_color       :string
#  position            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  focus_area_group_id :integer
#
# Indexes
#
#  index_focus_areas_on_deleted_at           (deleted_at)
#  index_focus_areas_on_focus_area_group_id  (focus_area_group_id)
#  index_focus_areas_on_position             (position)
#
class FocusArea < ApplicationRecord
  default_scope { order('focus_area_groups.position', :position).joins(:focus_area_group) }

  scope :ordered_by_group_position, lambda {
    includes(:focus_area_group)
      .order('focus_area_groups.position', 'focus_areas.position')
  }

  belongs_to :focus_area_group, inverse_of: :focus_areas
  has_many :characteristics, -> { order(position: :desc) }, dependent: :restrict_with_error, inverse_of: :focus_area

  # TODO: Add validations to the database schema
  validates :position, presence: true, uniqueness: { scope: :focus_area_group } # rubocop:disable Rails/UniqueValidationWithoutIndex

  delegate :scorecard_type, :workspace, to: :focus_area_group

  alias_attribute :color, :actual_color

  scope :per_data_model, lambda { |impact_card_data_model_id|
    joins(:focus_area_group)
      .where(
        'focus_area_groups.impact_card_data_model_id' => impact_card_data_model_id
      )
  }

  def short_name
    name.match(/(Goal\s\d*)\.*./)[1] || name
  end
end
