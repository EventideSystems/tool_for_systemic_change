# frozen_string_literal: true

class ScorecardChange < ApplicationRecord
  include ApplicationView

  belongs_to :scorecard
end
