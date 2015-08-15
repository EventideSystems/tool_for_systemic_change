# SMELL This whole class needs to be refactored. Doesn't make sense in the
# context of a "checklist"
class Initiative < ActiveRecord::Base
  belongs_to :wicked_problem
  has_and_belongs_to_many :organisations, join_table: :initiatives_organisations
end
