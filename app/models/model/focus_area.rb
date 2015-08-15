class Model::FocusArea < ActiveRecord::Base
  belongs_to :focus_area_group, class_name: 'Model::FocusAreaGroup'
  has_many  :initiative_characteristics, class_name: 'Model::InitiatveCharacteristic'
end
