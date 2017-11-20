# frozen_string_literal: true
class Scorecard < ApplicationRecord
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
      
      begin 
        PaperTrail.enabled = false

        copied.name = copy_name || "Copy of #{name}"
        copied.shared_link_id = new_shared_link_id
        copied.initiatives << initiatives.map { |initiative| initiative.deep_copy }
        copied.save!
  
        deep_copy_paper_trail_records(copied)
      ensure    
        PaperTrail.enabled = true
      end
    end
    
    copied 
  end
  
  def merge(other_scorecard)
    existing_initiative_names = initiatives.pluck(:name)
    
    other_scorecard.initiatives.each do |initiative|
      name = non_clashing_initiative_name(initiative.name, existing_initiative_names)
      existing_initiative_names << name unless existing_initiative_names.include?(name)
      
      initiative.update_attributes(scorecard_id: id, name: name)
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

    
    def deep_copy_paper_trail_records(copied)
      PaperTrail::Version.where(
        item_type: "Scorecard", 
        item_id: copied.id
      ).delete_all
     
      query = "
      INSERT INTO versions (item_type, item_id, event, whodunnit, object, created_at)
        SELECT item_type, '#{copied.id}', event, whodunnit, object, created_at
        FROM versions
        WHERE item_type = 'Scorecard' AND item_id = #{self.id}
      RETURNING *;
      "
      ActiveRecord::Base.connection.execute(query)
    end
end
