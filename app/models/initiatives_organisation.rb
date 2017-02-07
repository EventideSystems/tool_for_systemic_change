class InitiativesOrganisation < ApplicationRecord
  validates_presence_of :initiative, :organisation

  belongs_to :initiative
  belongs_to :organisation
end
