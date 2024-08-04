# == Schema Information
#
# Table name: communities
#
#  id          :integer          not null, primary key
#  deleted_at  :datetime
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
# Indexes
#
#  index_communities_on_account_id  (account_id)
#  index_communities_on_deleted_at  (deleted_at)
#
FactoryBot.define do
  factory :community do
    name { FFaker::Name.name }
    account
  end
end
