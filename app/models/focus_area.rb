class FocusArea < ActiveRecord::Base
  belongs_to :focus_area_group
  has_many  :characteristics
end
