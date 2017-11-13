# frozen_string_literal: true
class Scorecard < ApplicationRecord
  include Trackable
  has_paper_trail
  acts_as_paranoid

  after_initialize :ensure_shared_link_id, if: :new_record?

  belongs_to :community
  belongs_to :account
  belongs_to :wicked_problem
  has_many :initiatives, -> { order('lower(initiatives.name)') }, dependent: :destroy
  has_many :checklist_items, through: :initiatives
  
  delegate :name, :description, to: :wicked_problem, prefix: true, allow_nil: true
  delegate :name, :description, to: :community, prefix: true, allow_nil: true
  
  accepts_nested_attributes_for :initiatives,
    allow_destroy: true, 
    reject_if:  proc { |attributes| attributes['name'].blank? }

  validates :account, presence: true
  validates :name, presence: true
  validates :community, presence: true
  validates :wicked_problem, presence: true
  validates :shared_link_id, uniqueness: true
  
  def description_summary
    Nokogiri::HTML(description).text
  end
  
  def copy(copy_name)
    PublicActivity.enabled = false
    copied = self.dup
    
    ActiveRecord::Base.transaction do
      copied.name = copy_name || "Copy of #{name}"
      copied.shared_link_id = new_shared_link_id
    
      copied.initiatives << initiatives.map { |initiative| initiative.copy }
      copied.save!
    end
    
    copied
  end
  
  def deep_copy(copy_name)
    copied = self.dup
    
    ActiveRecord::Base.transaction do 
      PublicActivity.enabled = false

      copied.name = copy_name || "Copy of #{name}"
      copied.shared_link_id = new_shared_link_id
      copied.initiatives << initiatives.map { |initiative| initiative.deep_copy }
      copied.save!
  
      deep_copy_public_activity_records(copied)
      deep_copy_paper_trail_records(copied)
        
      PublicActivity.enabled = true
    end
    
    copied 
  end
  
  def merge(other_scorecard)
    existing_initiative_names = initiatives.pluck(:name)
    
    other_scorecard.initiatives.each do |initiative|
      initiative.update_attributes(
        scorecard_id: id, 
        name: non_clashing_initiative_name(
          initiative.name, 
          existing_initiative_names
        )
      )
    end
  
    other_scorecard.delete

    reload
  end

  private

    def non_clashing_initiative_name(name, existing_names)
      return name unless existing_names.include?(name)
      
      name_match = /(.*)(\s\(\d+\))$/.match(name)
      basename = name_match ? name_match[1] : name
      
      count = 1
      while true 
        new_name = "#{basename} (#{count})" 
        return new_name unless existing_names.include?(new_name)
        count += 1
      end
    end
    
    
    def ensure_shared_link_id
      self.shared_link_id ||= new_shared_link_id
    end
    
    def new_shared_link_id
      SecureRandom.uuid
    end
    
    def deep_copy_public_activity_records(copied)
      PublicActivity::Activity.where(
        trackable_type: "Scorecard", 
        trackable_id: copied.id
      ).delete_all
     
      original_scorecard_activities = PublicActivity::Activity.where(
        trackable_type: "Scorecard", 
        trackable_id: id
      )
    
      original_scorecard_activities.each do |activity|
        copied_activity = activity.dup
        copied_activity.trackable_id = copied.id
        copied_activity.created_at = activity.created_at
        copied_activity.updated_at = activity.updated_at
        copied_activity.save!
      end
    end
    
    def deep_copy_paper_trail_records(copied)
      PaperTrail::Version.where(
        item_type: "Scorecard", 
        item_id: copied.id
      ).delete_all
     
      original_scorecard_versions = PaperTrail::Version.where(
        item_type: "Scorecard", 
        item_id: id
      )
    
      original_scorecard_versions.each do |version|
        copied_version = version.dup
        copied_version.item_id = copied.id
        copied_version.created_at = version.created_at
        copied_version.save!
      end
    end
end
