class Client < ActiveRecord::Base
  acts_as_paranoid

  class NotAuthorized < Exception; end

  # SMELL Hack to allow these parameters to be used in RailsAdmin
  attr_accessor :initial_admin_user_name
  attr_accessor :initial_admin_user_email

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

  def active?
    !deactivated
  end
end
