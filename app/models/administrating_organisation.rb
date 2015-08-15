class AdministratingOrganisation < Organisation
  has_many :organisations
  has_many :communities
  has_many :wicked_problems
  has_many :users
end
