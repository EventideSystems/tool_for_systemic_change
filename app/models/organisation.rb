class Organisation < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :account
  belongs_to :sector
  has_many :initiative_organisations, dependent: :restrict_with_exception
  has_many :initiatives, through: :initiative_organisations

  # SMELL Dupe of scope in WickedProblem - move to a concern
  # NOTE No longer in use, use current account instead
  scope :for_user, ->(user) {
    unless user.staff?
      joins(:client).where('clients.id' => user.account_id)
    end
  }
end
