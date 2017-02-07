class Community < ApplicationRecord
  acts_as_paranoid

  include Trackable

  include PublicActivity::Model
  tracked
  
  belongs_to :account
  has_many :scorecards

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      where(client_id: user.client_id)
    end
  }
end
