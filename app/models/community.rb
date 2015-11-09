class Community < ActiveRecord::Base
  include Trackable

  belongs_to :client
  has_many :scorecards

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      where(client_id: user.client_id)
    end
  }
end
