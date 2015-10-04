class WickedProblem < ActiveRecord::Base
  belongs_to :client
  has_many :scorecards

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      joins(:client).where('clients.id' => user.client_id)
    end
  }

  validates :name, presence: true, :uniqueness => { :scope => :client_id }
end
