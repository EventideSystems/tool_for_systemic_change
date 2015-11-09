class ChecklistItem < ActiveRecord::Base
  include Trackable

  belongs_to :initiative
  belongs_to :characteristic

  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

end
