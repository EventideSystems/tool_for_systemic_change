class AdministratingOrganisation < Organisation
  has_many :organisations
  has_many :communities
end
