class InitiativeChecklistItem < ActiveRecord::Base
  belongs_to :initiative
  belongs_to :initiative_characteristic, class_name: 'Model::InitiativeCharacteristic'

  validates :initiative, presence: true
  validates :initiative_characteristic, presence: true, uniqueness: { scope: :initiative }
end
