# frozen_string_literal: true
class WickedProblem < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  has_many :scorecards, dependent: :restrict_with_error

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }
end
