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
require 'rails_helper'

RSpec.describe ScorecardTypeCharacteristic, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
