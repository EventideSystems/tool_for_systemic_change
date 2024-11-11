# frozen_string_literal: true

# == Schema Information
#
# Table name: stakeholder_types
#
#  id          :integer          not null, primary key
#  color       :string
#  deleted_at  :datetime
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
# Indexes
#
#  index_stakeholder_types_on_account_id  (account_id)
#
FactoryBot.define do
  factory :stakeholder_type do
    name { FFaker::Name.name }
  end
end
