class ChecklistItem < ActiveRecord::Base
  acts_as_paranoid

  include Trackable

  belongs_to :initiative
  belongs_to :characteristic

  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

  def name
   characteristic.name
  end

end
