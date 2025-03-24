# frozen_string_literal: true

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
#  stakeholder_type_id :integer
#  workspace_id        :integer
#
# Indexes
#
#  index_organisations_on_deleted_at    (deleted_at)
#  index_organisations_on_workspace_id  (workspace_id)
#
FactoryBot.define do
  factory :organisation do
    stakeholder_type
    workspace
    name { FFaker::Name.name }
  end
end
