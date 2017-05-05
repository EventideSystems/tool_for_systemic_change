# frozen_string_literal: true
class Initiative < ApplicationRecord
  include Trackable
  
  acts_as_paranoid

  belongs_to :scorecard
  has_many :initiatives_organisations, dependent: :destroy
  has_many :organisations, through: :initiatives_organisations
  has_many :checklist_items, dependent: :destroy
  has_many :characteristics, through: :checklist_items
  
  accepts_nested_attributes_for :initiatives_organisations, 
    allow_destroy: true, 
    reject_if:  proc { |attributes| attributes['organisation_id'].blank? }

  validates :name, presence: true
  validate :validate_finished_at_later_than_started_at

  after_create :create_checklist_items
  
  delegate :name, to: :scorecard, prefix: true
  
  scope :incomplete, -> {
    joins(:checklist_items)
    .where('checklist_items.checked is NULL or checklist_items.checked = false').distinct
  }
  
  # SMELL Lazy way
  scope :complete, -> {
    where.not(id: Initiative.incomplete.pluck(:id))
  }
  
  scope :overdue, -> {
    finished_at = Initiative.arel_table[:finished_at]
    incomplete.where(finished_at.lt(Date.today)).where(dates_confirmed: true)
  }
  
  def checklist_items_ordered_by_ordered_focus_area
    ChecklistItem.includes(characteristic: {focus_area: :focus_area_group})
     .where('checklist_items.initiative_id' => self.id)
     .order('focus_area_groups.position', 'focus_areas.position', 'characteristics.position')
     .all
  end
  
  def wicked_problem_name
    scorecard.try(:wicked_problem).try(:name)
  end

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
    return true unless started_at.present? && finished_at.present? 
    finished_at > started_at
  end
end
