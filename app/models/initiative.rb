# frozen_string_literal: true
class Initiative < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :scorecard, optional: true
  has_many :initiatives_organisations, dependent: :destroy
  has_many :initiatives_subsystem_tags, dependent: :destroy
  has_many :organisations, through: :initiatives_organisations
  has_many :subsystem_tags, through: :initiatives_subsystem_tags
  has_many :checklist_items, dependent: :destroy
  has_many :characteristics, through: :checklist_items
  
  accepts_nested_attributes_for :initiatives_organisations, 
    allow_destroy: true, 
    reject_if:  proc { |attributes| attributes['organisation_id'].blank? }

  accepts_nested_attributes_for :initiatives_subsystem_tags, 
    allow_destroy: true, 
    reject_if:  proc { |attributes| attributes['subsystem_tag_id'].blank? }

  validates :name, presence: true
  validate :validate_finished_at_not_earlier_than_started_at

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
  
  def checklist_items_ordered_by_ordered_focus_area(selected_date: nil, focus_areas: nil)
    checklist_items = ChecklistItem.includes(characteristic: {focus_area: :focus_area_group})
     .where('checklist_items.initiative_id' => self.id)
     .order('focus_area_groups.position', 'focus_areas.position', 'characteristics.position')
     .all
     
     checklist_items = checklist_items.select { |checklist_item| checklist_item.focus_area.id.in?(focus_areas.map(&:id)) } if focus_areas.present? 
     
     checklist_items = checklist_items.map { |checklist_item| checklist_item.snapshot_at(selected_date.end_of_day) } if selected_date.present?
     
     checklist_items
  end
  
  def wicked_problem_name
    scorecard.try(:wicked_problem).try(:name)
  end
  
  def copy
    copied = self.dup
    organisations.each do |organisation|
      copied.initiatives_organisations.build(organisation: organisation)
    end
    copied.save!
    
    copied
  end
  
  def deep_copy
    copied = self.dup
    organisations.each do |organisation|
      copied.initiatives_organisations.build(organisation: organisation)
    end    
    
    copied.save!
    copied.checklist_items.delete_all
    
    query = "
    INSERT INTO checklist_items (checked, comment, characteristic_id, initiative_id, created_at, updated_at)
      SELECT checked, comment, characteristic_id, '#{copied.id}', created_at, updated_at
      FROM checklist_items
      WHERE initiative_id = #{self.id}
    RETURNING *;
    "
    ActiveRecord::Base.connection.execute(query)
   
    delay.deep_copy_paper_trail_records(copied)
    
    copied.reload
  end

  private

  def create_checklist_items
    characteristic_ids = Characteristic.all.pluck(:id) - checklist_items.map(&:characteristic_id)
    Characteristic.where(id: characteristic_ids).all.each do |characteristic|
      checklist_items.create(characteristic: characteristic)
    end
  end
  
  def deep_copy_paper_trail_records(copied)
    PaperTrail::Version.where(
      item_type: "Initiative", 
      item_id: copied.id
    ).delete_all
     
    original_initiative_versions = PaperTrail::Version.where(
      item_type: "Initiative", 
      item_id: id
    )

    query = "
    INSERT INTO versions (item_type, item_id, event, whodunnit, object, created_at)
      SELECT item_type, '#{copied.id}', event, whodunnit, object, created_at
      FROM versions
      WHERE item_type = 'Initiative' AND item_id = #{self.id}
    RETURNING *;
    "
    ActiveRecord::Base.connection.execute(query)
    
    PaperTrail::Version.where(
      item_type: "ChecklistItem", 
      item_id: copied.checklist_items.map(&:id)
    ).delete_all
    
    original_checklist_item_versions = PaperTrail::Version.where(
      item_type: "ChecklistItem", 
      item_id: checklist_items.map(&:id)
    )
    
    original_checklist_item_versions.each do |version|
      copied_version = version.dup
      
      item_id = ChecklistItem.where(
        initiative_id: copied.id,
        characteristic_id: version.item.characteristic.id
      ).first.id
      
      copied_version.item_id = item_id
      copied_version.created_at = version.created_at
      copied_version.save!
    end    
  end

  def validate_finished_at_not_earlier_than_started_at
    errors.add(:finished_at, "can't be earlier than started at date") unless finished_at_not_earlier_than_started_at
  end

  def finished_at_not_earlier_than_started_at
    return true unless started_at.present? && finished_at.present?
    finished_at >= started_at
  end
end
