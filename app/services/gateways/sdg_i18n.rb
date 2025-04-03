# frozen_string_literal: true

require 'open-uri'
require 'yaml'

module Gateways
  # This class is responsible for fetching SDG I18n data from the Consul Democracy project on Github.
  # See: https://github.com/consuldemocracy/consuldemocracy
  #
  # NOTE We might consider a fallback to the Open SDG project. See https://github.com/open-sdg/sdg-translations.
  #
  # We'll extend this further to allow for language selection and other features.
  #
  # NOTE: This is a very simple client. It does not handle error handling in a robust way.
  # It is assumed that the data is always available and in the correct format.
  class SdgI18n
    BASE_URI = 'https://raw.githubusercontent.com/consuldemocracy/consuldemocracy/refs/heads/master/config/locales/en/sdg.yml'

    def fetch_indicators
      get_data('global_indicators.yml')
    end

    def fetch_goals_and_targets
      select_goal_data.transform_keys { |k| k.split('_').last }.transform_values do |values|
        {
          'short_title' => values['title'],
          'long_title' => values['description'],
          'targets' => values['targets'].transform_keys { |k| k.gsub('target_', '').tr('_', '.').downcase }
        }.with_indifferent_access
      end
    end

    private

    def raw_data
      @raw_data ||= fetch_raw_data
    end

    def select_goal_data
      raw_data['goals'].select do |k, _|
        k.include?('goal_')
      end
    end

    def fetch_raw_data
      uri = URI(BASE_URI)
      response = uri.open
      YAML.load(response.read).dig('en', 'sdg')
    rescue StandardError => e
      Rails.logger.debug "Failed to fetch data from the Consul Democracy project: #{e.message}"
    end
  end
end
