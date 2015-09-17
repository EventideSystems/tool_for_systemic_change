class Client < ActiveRecord::Base
  has_many :organisations
  has_many :communities
  has_many :wicked_problems
  has_many :users
  belongs_to :sector

  # SMELL
  scope :for_user, ->(user) {
    unless user.staff?
      where(id: user.client.id)
    end
  }
end
