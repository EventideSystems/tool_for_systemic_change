# frozen_string_literal: true

# Helper methods for presenting impact card data models
module ImpactCardDataModelHelper
  def impact_card_data_model_filter_label(impact_card_data_model)
    if impact_card_data_model.workspace == current_workspace
      'Current Workspace'
    elsif impact_card_data_model.system_model?
      'System'
    else
      'Other Workspace'
    end
  end

  def impact_card_data_model_filter_color(impact_card_data_model)
    if impact_card_data_model.workspace == current_workspace
      'bg-green-400 green-900'
    elsif impact_card_data_model.system_model?
      'bg-red-400 red-900'
    else
      'bg-blue-400 blue-900'
    end
  end

  def display_name(element)
    [element.code, element.short_name.presence || element.name].compact.join(' ')
  end
end
