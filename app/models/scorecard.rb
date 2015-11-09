class Scorecard < ActiveRecord::Base
  include Trackable

  belongs_to :community
  belongs_to :client
  belongs_to :wicked_problem
  has_many :initiatives
  has_many :checklist_items, through: :initiatives

  validates :client, presence: true
  validates :community, presence: true
  validates :wicked_problem, presence: true

  scope :for_user, ->(user) {
    unless user.staff?
      where(client_id: user.client_id)
    end
  }
end
