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
class ScorecardChange < ApplicationRecord
  include ApplicationView

  belongs_to :scorecard
end
