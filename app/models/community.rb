class Community < ActiveRecord::Base
  belongs_to :client
  has_many :wicked_problems

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      where(client_id: user.client_id)
    end
  }
end
