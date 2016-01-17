class Scorecard < ActiveRecord::Base
  include Trackable

  before_save :ensure_shared_link_id

  belongs_to :community
  belongs_to :client
  belongs_to :wicked_problem
  has_many :initiatives
  has_many :checklist_items, through: :initiatives

  validates :client, presence: true
  validates :community, presence: true
  validates :wicked_problem, presence: true
  validates :shared_link_id, uniqueness: true

  scope :for_user, ->(user) {
    unless user.staff?
      where(client_id: user.client_id)
    end
  }

  private

    def ensure_shared_link_id
      self.shared_link_id = shared_link_id.presence || SecureRandom.uuid
    end
end
