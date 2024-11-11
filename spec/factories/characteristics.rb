# frozen_string_literal: true

# == Schema Information
#
# Table name: characteristics
#
#  id            :integer          not null, primary key
#  deleted_at    :datetime
#  description   :string
#  name          :string
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  focus_area_id :integer
#
# Indexes
#
#  index_characteristics_on_deleted_at     (deleted_at)
#  index_characteristics_on_focus_area_id  (focus_area_id)
#  index_characteristics_on_position       (position)
#
FactoryBot.define do
  sequence(:characteristic_position) { |n| n }

  factory :characteristic do
    name { FFaker::Name.name }
    focus_area
    position { generate(:characteristic_position) }
  end
end
