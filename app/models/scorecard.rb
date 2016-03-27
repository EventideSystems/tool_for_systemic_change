class Scorecard < ActiveRecord::Base
  acts_as_paranoid

  include Trackable

  after_initialize :ensure_shared_link_id, :if => :new_record?

  belongs_to :community
  belongs_to :client
  belongs_to :wicked_problem
  has_many :initiatives, dependent: :destroy
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
      self.shared_link_id ||= SecureRandom.uuid
    end
end
