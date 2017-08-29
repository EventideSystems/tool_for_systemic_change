# frozen_string_literal: true
class Account < ApplicationRecord
  include Trackable
  
  acts_as_paranoid

  enum subcription_type: { standard: 0, twelve_month_single_scorecard: 1 }
  
  belongs_to :sector
  has_many :accounts_users
  has_many :users, through: :accounts_users
  has_many :organisations
  has_many :communities
  has_many :scorecards
  has_many :initiatives, through: :scorecards
  has_many :wicked_problems
  has_many :organisations_imports, class_name: 'Organisations::Import'
  
  validates :name, presence: true
  
  def accounts_users_remaining
    return :unlimited if max_users == 0 
    max_users - accounts_users.count
  end
  
end

