class Model::InitiativeCharacteristic < ActiveRecord::Base
  belongs_to :focus_area, class_name: 'Model::FocusArea'
end
