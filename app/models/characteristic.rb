# frozen_string_literal: true

# == Schema Information
#
# Table name: characteristics
#
#  id            :integer          not null, primary key
#  code          :string
#  color         :string
#  deleted_at    :datetime
#  description   :string
#  name          :string
#  position      :integer
#  short_name    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  focus_area_id :integer
#
# Indexes
#
#  index_characteristics_on_deleted_at              (deleted_at)
#  index_characteristics_on_focus_area_id           (focus_area_id)
#  index_characteristics_on_focus_area_id_and_code  (focus_area_id,code) UNIQUE
#  index_characteristics_on_position                (position)
#
class Characteristic < ApplicationRecord
  acts_as_paranoid

  include ValidateUniqueCode
  include DataElementable

  default_scope { order('focus_areas.position', :position).joins(:focus_area) }

  belongs_to :focus_area
  has_many :checklist_items, dependent: :nullify

  # TODO: Add validations to the database schema (taking into account the deleted_at column)
  validates :position, presence: true, uniqueness: { scope: :focus_area } # rubocop:disable Rails/UniqueValidationWithoutIndex
  delegate :position, to: :focus_area, prefix: true # TODO: Check if this is needed, see `identifier` method below

  delegate :data_model, to: :focus_area
  delegate :workspace, to: :focus_area

  # Required by the DataElementable concern
  alias parent focus_area

  scope :per_data_model, lambda { |data_model_id|
    joins(focus_area: :focus_area_group)
      .where(
        'focus_area_groups_focus_areas.data_model_id' => data_model_id
      )
  }

  # TODO: Check if this is needed
  def identifier
    "#{focus_area.position}.#{position}"
  end
end
