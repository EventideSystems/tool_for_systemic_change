class WickedProblem < ActiveRecord::Base
  belongs_to :community
  belongs_to :administrating_organisation, class_name: 'AdministratingOrganisation'
  has_many :initiatives

  scope :for_user, ->(user) {
    unless user.staff?
      where(administrating_organisation_id: user.administrating_organisation_id)
    end
  }
end
