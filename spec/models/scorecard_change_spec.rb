# frozen_string_literal: true

# == Schema Information
#
# Table name: scorecard_changes
#
#  action              :string
#  activity            :string
#  characteristic_name :string
#  comment             :string
#  from_value          :string
#  initiative_name     :string
#  occurred_at         :datetime
#  to_value            :string
#  scorecard_id        :integer
#
require 'rails_helper'

RSpec.describe ScorecardChange, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
