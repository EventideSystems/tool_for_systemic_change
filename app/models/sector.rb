# frozen_string_literal: true
class Sector < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true, uniqueness: { scope: :account_id }
  
  has_many :accounts
end
