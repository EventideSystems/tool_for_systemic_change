# frozen_string_literal: true

# SDG Data Model Loader, responsible for loading SDG data models into the system.
# This service interacts with the SDG API to fetch data and populate the database.
#
# @example
#   loader = SdgDataModelLoader.new
#   loader.load_data_models
#
# @see Gateways::SdgApi
# @see FocusAreaGroup
# @see FocusArea
# @see Indicator
class SdgDataModelLoader
  def initialize
    @sdg_api = Gateways::SdgApi.new
  end

  def load_data_models
    load_focus_area_groups
    load_focus_areas
    load_indicators
  end

  private

  def load_focus_area_groups
    focus_area_groups = @sdg_api.fetch_goals.map do |goal|
      FocusAreaGroup.find_or_create_by(code: goal['code']) do |group|
        group.name = goal['name']
        group.description = goal['description']
        group.position = goal['position']
      end
    end

    focus_area_groups.each(&:save)
  end

  def load_focus_areas
    focus_areas = @sdg_api.fetch_targets.map do |target|
      FocusArea.find_or_create_by(code: target['code']) do |area|
        area.name = target['name']
        area.description = target['description']
        area.position = target['position']
      end
    end

    focus_areas.each(&:save)
  end

  def load_indicators
    indicators = @sdg_api.fetch_indicators.map do |indicator|
      Indicator.find_or_create_by(code: indicator['code']) do |ind|
        ind.name = indicator['name']
        ind.description = indicator['description']
        ind.position = indicator['position']
      end
    end

    indicators.each(&:save)
  end
end
