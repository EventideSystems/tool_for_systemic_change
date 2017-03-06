# frozen_string_literal: true
class Community < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :account
  has_many :scorecards
  
  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }
end
