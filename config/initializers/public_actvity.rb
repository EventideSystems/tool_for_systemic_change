require 'public_activity'

Trackable.include PublicActivity::Model

[ Account,
  ChecklistItem,
  Community,
  Initiative,
  Organisation,
  Scorecard,
  User,
  
  WickedProblem
].each { |klass| klass.include Trackable }