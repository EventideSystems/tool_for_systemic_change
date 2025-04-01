# frozen_string_literal: true

# == Schema Information
#
# Table name: communities
#
#  id           :integer          not null, primary key
#  color        :string           default("#f7f80a"), not null
#  deleted_at   :datetime
#  description  :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :integer
#
# Indexes
#
#  index_communities_on_deleted_at    (deleted_at)
#  index_communities_on_workspace_id  (workspace_id)
#
FactoryBot.define do
  factory :community do
    name { FFaker::Name.name }
    # workspace
  end
end
