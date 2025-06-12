# frozen_string_literal: true

# == Schema Information
#
# Table name: wicked_problems
#
#  id           :integer          not null, primary key
#  color        :string           default("#b98615"), not null
#  deleted_at   :datetime
#  description  :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :integer
#
# Indexes
#
#  index_wicked_problems_on_deleted_at    (deleted_at)
#  index_wicked_problems_on_workspace_id  (workspace_id)
#
FactoryBot.define do
  factory :wicked_problem do
    name { FFaker::Name.name }
    # workspace
  end
end
