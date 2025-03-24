# frozen_string_literal: true

# == Schema Information
#
# Table name: workspaces_users
#
#  id             :integer          not null, primary key
#  workspace_role :integer          default("member")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  workspace_id   :integer
#
# Indexes
#
#  index_workspaces_users_on_user_id                   (user_id)
#  index_workspaces_users_on_workspace_id              (workspace_id)
#  index_workspaces_users_on_workspace_id_and_user_id  (workspace_id,user_id) UNIQUE
#
FactoryBot.define do
  factory :workspaces_user do
    workspace
    user
    workspace_role { :member }
  end
end
