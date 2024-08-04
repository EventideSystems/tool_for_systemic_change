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
require 'rails_helper'

RSpec.describe TargetsNetworkMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
