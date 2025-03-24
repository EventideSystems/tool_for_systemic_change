# frozen_string_literal: true

# == Schema Information
#
# Table name: scorecard_type_characteristics
#
#  id             :integer
#  deleted_at     :datetime
#  description    :string
#  name           :string
#  position       :integer
#  scorecard_type :string
#  created_at     :datetime
#  updated_at     :datetime
#  focus_area_id  :integer
#  workspace_id   :bigint
#
class ScorecardTypeCharacteristic < ApplicationRecord
  include ApplicationView
end
