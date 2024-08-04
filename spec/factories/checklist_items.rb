# frozen_string_literal: true

# == Schema Information
#
# Table name: checklist_items
#
#  id                         :integer          not null, primary key
#  checked                    :boolean
#  comment                    :text
#  deleted_at                 :datetime
#  status                     :string           default("no_comment")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  characteristic_id          :integer
#  initiative_id              :integer
#  previous_characteristic_id :bigint
#  user_id                    :bigint
#
# Indexes
#
#  index_checklist_items_on_characteristic_id  (characteristic_id)
#  index_checklist_items_on_deleted_at         (deleted_at)
#  index_checklist_items_on_initiative_id      (initiative_id)
#  index_checklist_items_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (previous_characteristic_id => characteristics.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :checklist_item do
    # characteristic
    # initiative
  end
end
