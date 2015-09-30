class Scorecard < ActiveRecord::Base
  belongs_to :community
  belongs_to :client, class_name: 'Client'
  has_many :initiatives

  scope :for_user, ->(user) {
    unless user.staff?
      where(client_id: user.client_id)
    end
  }

  validates :client, presence: true
  validates :community, presence: true
end
