# frozen_string_literal: true
class Scorecard < ApplicationRecord
  include Trackable
  has_paper_trail
  acts_as_paranoid

  after_initialize :ensure_shared_link_id, if: :new_record?

  belongs_to :community
  belongs_to :account
  belongs_to :wicked_problem
  has_many :initiatives, dependent: :destroy
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

  private

    def ensure_shared_link_id
      self.shared_link_id ||= SecureRandom.uuid
    end
end
