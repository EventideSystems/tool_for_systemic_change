class Model::FocusAreaGroup < ActiveRecord::Base
  has_many :focus_areas, class_name: 'Model::FocusArea'
end
