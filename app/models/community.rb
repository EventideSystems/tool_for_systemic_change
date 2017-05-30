# frozen_string_literal: true
class Community < ApplicationRecord
  include Trackable
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  has_many :scorecards
  
  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }
end
