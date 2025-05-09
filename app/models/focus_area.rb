# frozen_string_literal: true

# == Schema Information
#
# Table name: focus_areas
#
#  id                  :integer          not null, primary key
#  code                :string
#  color               :string
#  deleted_at          :datetime
#  description         :string
#  icon_name           :string           default("")
#  name                :string
#  position            :integer
#  short_name          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  focus_area_group_id :integer
#
# Indexes
#
#  index_focus_areas_on_deleted_at                    (deleted_at)
#  index_focus_areas_on_focus_area_group_id           (focus_area_group_id)
#  index_focus_areas_on_focus_area_group_id_and_code  (focus_area_group_id,code) UNIQUE
#  index_focus_areas_on_position                      (position)
#
class FocusArea < ApplicationRecord
  include RandomColorAttribute
  include ValidateUniqueCode
  include DataElementable

  default_scope { order('focus_area_groups.position', :position).joins(:focus_area_group) }

  scope :ordered_by_group_position, lambda {
    includes(:focus_area_group)
      .order('focus_area_groups.position', 'focus_areas.position')
  }

  belongs_to :focus_area_group, inverse_of: :focus_areas
  has_many :characteristics, -> { order(position: :desc) }, dependent: :restrict_with_error, inverse_of: :focus_area

  # TODO: Add validations to the database schema (taking into account the deleted_at column)
  validates :position, presence: true, uniqueness: { scope: :focus_area_group } # rubocop:disable Rails/UniqueValidationWithoutIndex

  delegate :workspace, to: :focus_area_group
  delegate :data_model, to: :focus_area_group

  # Required by the DataElementable concern
  alias children characteristics
  alias parent focus_area_group

  scope :per_data_model, lambda { |data_model_id|
    joins(:focus_area_group)
      .where(
        'focus_area_groups.data_model_id' => data_model_id
      )
  }
end
