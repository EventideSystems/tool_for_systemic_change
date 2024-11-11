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
#  account_id     :bigint
#
# Indexes
#
#  index_focus_area_groups_on_account_id      (account_id)
#  index_focus_area_groups_on_deleted_at      (deleted_at)
#  index_focus_area_groups_on_position        (position)
#  index_focus_area_groups_on_scorecard_type  (scorecard_type)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class FocusAreaGroup < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:position) }

  attr_accessor :video_tutorial_id

  belongs_to :account, optional: true

  has_many :focus_areas, dependent: :restrict_with_error
  has_one :video_tutorial, as: :linked

  validates :position, presence: true

  def video_tutorial_id=(value)
    return if value.blank?

    tutorial = VideoTutorial.where(id: value).first
    tutorial&.update_attribute(:linked, self)
  end

  def video_tutorial_id
    video_tutorial.try(:id)
  end
end
