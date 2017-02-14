class WickedProblem < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :client
  has_many :scorecards, dependent: :restrict_with_error

  # # SMELL Dupe of scope in WickedProblem - move to a concern
  # scope :for_user, ->(user) {
  #   unless user.staff?
  #     joins(:client).where('clients.id' => user.account_id)
  #   end
  # }

  validates :name, presence: true, :uniqueness => { :scope => :account_id }
end
