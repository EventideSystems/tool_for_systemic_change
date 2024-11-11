# frozen_string_literal: true

json.array! @scorecards, partial: 'scorecards/scorecard', as: :scorecard
