# == Schema Information
#
# Table name: focus_area_groups
#
#  id             :integer          not null, primary key
#  deleted_at     :datetime
#  description    :string
#  name           :string
#  position       :integer
#  scorecard_type :string           default("TransitionCard")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint
#
# Indexes
#
#  index_focus_area_groups_on_account_id      (account_id)
#  index_focus_area_groups_on_deleted_at      (deleted_at)
#  index_focus_area_groups_on_position        (position)
#  index_focus_area_groups_on_scorecard_type  (scorecard_type)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  sequence(:focus_area_group_position) { |n| n }
  
  factory :focus_area_group do
    name { FFaker::Name.name }
    position { generate(:focus_area_group_position) }
  end
end
