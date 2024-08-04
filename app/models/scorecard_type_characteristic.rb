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
#  account_id     :bigint
#  focus_area_id  :integer
#
class ScorecardTypeCharacteristic < ApplicationRecord
  include ApplicationView
end
