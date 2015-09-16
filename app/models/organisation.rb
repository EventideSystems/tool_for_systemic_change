class Organisation < ActiveRecord::Base
  belongs_to :client
  belongs_to :sector
  has_and_belongs_to_many :intiatives, join_table: :initiatives_organisations, class_name: 'Initiative'

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      joins(:client).where('clients.id' => user.client_id)
    end
  }
end
