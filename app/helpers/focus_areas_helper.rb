# frozen_string_literal: true

# Helper methods for presenting focus areas
module FocusAreasHelper
  def focus_area_icon(focus_area)
    image_tag("sdg_icons/#{focus_area.icon_name}", class: 'focus-area-icon')
  end

  def focus_area_model_name(focus_area)
    case focus_area.scorecard_type
    when 'TransitionCard'
      focus_area.account&.transition_card_focus_area_model_name
    when 'SustainableDevelopmentGoalAlignmentCard'
      focus_area.account&.sdgs_alignment_card_focus_area_model_name
    end || focus_area.model_name.human.titleize
  end

  def options_for_icon_name
    Dir.glob(Rails.root.join('app/assets/images/sdg_icons/E-WEB-Goal-*.png')).map do |path|
      [path.split('/').last, path.split('/').last]
    end.sort
  end
end
