class AdministratingOrganisation < Organisation
  has_many :organisations
  has_many :communities
  has_many :wicked_problems
  has_many :users

  # SMELL
  scope :for_user, ->(user) {
    unless user.staff?
      where(id: user.administrating_organisation.id)
    end
  }
end
