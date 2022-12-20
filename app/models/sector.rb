# frozen_string_literal: true
class Sector < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :account, optional: true

  has_many :accounts

  scope :system_sectors, -> { where(account_id: nil) }

  def system_sector?
    account_id.nil?
  end
end
