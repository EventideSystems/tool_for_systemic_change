# frozen_string_literal: true

# == Schema Information
#
# Table name: targets_network_mappings
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  characteristic_id :bigint
#  focus_area_id     :bigint
#
# Indexes
#
#  index_targets_network_mappings_on_characteristic_id  (characteristic_id)
#  index_targets_network_mappings_on_focus_area_id      (focus_area_id)
#
class TargetsNetworkMapping < ApplicationRecord
  belongs_to :focus_area
  belongs_to :characteristic
end
