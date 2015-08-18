class Community < ActiveRecord::Base
  belongs_to :administrating_organisation
  has_many :wicked_problems

  scope :for_user, ->(user) {
    unless user.staff?
      where(administrating_organisation_id: user.administrating_organisation.id)
    end
  }
end
