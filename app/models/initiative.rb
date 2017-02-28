# frozen_string_literal: true
class Initiative < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :scorecard
  has_many :initiatives_organisations, dependent: :destroy
  has_many :organisations, through: :initiatives_organisations
  has_many :checklist_items, dependent: :destroy
  has_many :characteristics, through: :checklist_items
  
  accepts_nested_attributes_for :initiatives_organisations

  validates :name, presence: true
  validate :validate_finished_at_later_than_started_at

  after_create :create_checklist_items

  private

  def create_checklist_items
    Characteristic.all.find_each do |characteristic|
      ChecklistItem.create!(
        initiative: self, characteristic: characteristic
      )
    end
  end

  def validate_finished_at_later_than_started_at
    errors.add(:finished_at, "can't be earlier than started at date") unless finished_at_later_than_started_at
  end

  def finished_at_later_than_started_at
    started_at.present? && finished_at.present? && finished_at > started_at
  end
end
