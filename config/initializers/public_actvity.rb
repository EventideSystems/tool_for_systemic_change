require 'public_activity'

[ Account,
  ChecklistItem,
  Community,
  Initiative,
  Organisation,
  Scorecard,
  User,
  
  WickedProblem
].each { |klass| klass.include Trackable }