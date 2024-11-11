# frozen_string_literal: true

json.extract! scorecard, :id, :created_at, :updated_at
json.url scorecard_url(scorecard, format: :json)
