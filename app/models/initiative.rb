class Initiative < ActiveRecord::Base
  belongs_to :problem
  has_and_belongs_to_many :organisations, join_table: :initiative_organisations
end
