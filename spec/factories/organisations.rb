# == Schema Information
#
# Table name: organisations
#
#  id                  :integer          not null, primary key
#  deleted_at          :datetime
#  description         :string
#  name                :string
#  weblink             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :integer
#  stakeholder_type_id :integer
#
# Indexes
#
#  index_organisations_on_account_id  (account_id)
#  index_organisations_on_deleted_at  (deleted_at)
#
FactoryBot.define do
  factory :organisation do
    stakeholder_type
    account
    name { FFaker::Name.name }
  end
end
