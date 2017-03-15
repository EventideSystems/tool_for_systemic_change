# frozen_string_literal: true
class Organisation < ApplicationRecord
  acts_as_paranoid

  belongs_to :account
  belongs_to :sector
  has_many :initiative_organisations, dependent: :restrict_with_exception
  has_many :initiatives, through: :initiative_organisations

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }

end
