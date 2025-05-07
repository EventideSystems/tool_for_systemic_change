# frozen_string_literal: true

# == Schema Information
#
# Table name: subsystem_tags
#
#  id           :integer          not null, primary key
#  color        :string           default("#8907c3"), not null
#  deleted_at   :datetime
#  description  :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :integer
#
# Indexes
#
#  index_subsystem_tags_on_deleted_at    (deleted_at)
#  index_subsystem_tags_on_workspace_id  (workspace_id)
#
FactoryBot.define do
  factory :subsystem_tag do
    name { FFaker::Name.name }
  end
end
