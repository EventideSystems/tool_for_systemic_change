class Client < ActiveRecord::Base
  has_many :organisations
  has_many :communities
  has_many :scorecards
  has_many :users
  has_many :initiatives, through: :scorecards
  has_many :wicked_problems
  belongs_to :sector

  scope :for_user, ->(user) {
    unless user.staff?
      where(id: user.client.id)
    end
  }
end
