# frozen_string_literal: true

# == Schema Information
#
# Table name: video_tutorials
#
#  id                   :integer          not null, primary key
#  deleted_at           :datetime
#  description          :text
#  link_url             :string
#  linked_type          :string
#  name                 :string
#  position             :integer
#  promote_to_dashboard :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  linked_id            :integer
#
# Indexes
#
#  index_video_tutorials_on_deleted_at                 (deleted_at)
#  index_video_tutorials_on_linked_type_and_linked_id  (linked_type,linked_id)
#
FactoryBot.define do
  factory :video_tutorial do
  end
end
