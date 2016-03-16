class Organisation < ActiveRecord::Base
  acts_as_paranoid

  include Trackable

  belongs_to :client
  belongs_to :sector
  has_many :initiative_organisations, dependent: :restrict_with_exception
  has_many :initiatives, through: :initiative_organisations

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      joins(:client).where('clients.id' => user.client_id)
    end
  }
end
