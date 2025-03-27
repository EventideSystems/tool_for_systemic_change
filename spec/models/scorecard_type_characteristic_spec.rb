# frozen_string_literal: true

# == Schema Information
#
# Table name: scorecard_type_characteristics
#
#  id                        :integer
#  deleted_at                :datetime
#  description               :string
#  name                      :string
#  position                  :integer
#  created_at                :datetime
#  updated_at                :datetime
#  focus_area_id             :integer
#  impact_card_data_model_id :bigint
#  workspace_id              :bigint
#
require 'rails_helper'

RSpec.describe ScorecardTypeCharacteristic, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
