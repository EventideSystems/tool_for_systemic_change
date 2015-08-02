class Organisation < ActiveRecord::Base
  belongs_to :adminstraiting_organisation
  has_and_belongs_to_many :intiatives, join_table: :initiative_organisations
end
