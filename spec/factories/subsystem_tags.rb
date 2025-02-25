# frozen_string_literal: true

# == Schema Information
#
# Table name: subsystem_tags
#
#  id          :integer          not null, primary key
#  color       :string           default("#a04b50"), not null
#  deleted_at  :datetime
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
# Indexes
#
#  index_subsystem_tags_on_account_id  (account_id)
#  index_subsystem_tags_on_deleted_at  (deleted_at)
#
FactoryBot.define do
  factory :subsystem_tag do
    name { FFaker::Name.name }
  end
end
