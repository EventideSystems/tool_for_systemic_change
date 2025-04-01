# frozen_string_literal: true

require 'open-uri'
require 'json'

module Gateways
  # This class is responsible for interacting with the SDG API.
  # It provides methods to fetch data related to SDGs, targets, and indicators.
  class SdgApi
    BASE_URI = 'https://unstats.un.org/SDGAPI/v1/sdg/'
    # The base URI for the SDG API.

    def fetch_indicators
      get_data('Indicator/List')
    end

    def fetch_goals
      get_data('Goal/List')
    end

    def fetch_targets
      get_data('Target/List')
    end

    private

    def get_data(endpoint)
      uri = URI.join(BASE_URI, endpoint)
      response = uri.open

      JSON.parse(response.read)
    rescue StandardError => e
      Rails.logger.debug "Failed to fetch data from SDG API: #{e.message}"
      nil
    end
  end
end
