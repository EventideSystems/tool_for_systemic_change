# frozen_string_literal: true
class Organisation < ApplicationRecord
  include Trackable
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  belongs_to :sector
  has_many :initiatives_organisations, dependent: :restrict_with_exception
  has_many :initiatives, through: :initiatives_organisations

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :sector_id, presence: true

  delegate :name, to: :sector, prefix: true, allow_nil: true
end
