# frozen_string_literal: true
class StakeholderType < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :account, optional: true

  has_many :accounts
  has_many :organisations

  before_destroy :check_no_longer_used!, prepend: true

  scope :system_stakeholder_types, -> { where(account_id: nil) }

  def in_use?
    organisations.any?
  end

  def system_stakeholder_type?
    account_id.nil?
  end

  private

  def check_no_longer_used!
    return true if organisations.empty?
    errors.add(:base, "This stakeholder type is still in use")
    throw(:abort)
  end
end
