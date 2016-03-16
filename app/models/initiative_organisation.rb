class InitiativeOrganisation < ActiveRecord::Base
  self.table_name = 'initiatives_organisations'
  validates_presence_of :initiative, :organisation

  belongs_to :initiative
  belongs_to :organisation
end
