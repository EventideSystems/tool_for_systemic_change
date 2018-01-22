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

  delegate :name, to: :sector, prefix: true, allow_nil: true
end
