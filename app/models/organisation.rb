# frozen_string_literal: true
class Organisation < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  belongs_to :sector
  has_many :initiatives_organisations, dependent: :delete_all
  has_many :initiatives, through: :initiatives_organisations

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :sector_id, presence: true
  validate :sector_is_in_same_account

  delegate :name, to: :sector, prefix: true, allow_nil: true

  accepts_nested_attributes_for :initiatives_organisations, reject_if: :all_blank, allow_destroy: true

  private

  def sector_is_in_same_account
    errors.add(:sector_id, "must be in the same account") if sector && sector.account_id != account_id
  end
end
