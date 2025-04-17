# frozen_string_literal: true

# Helper methods for presenting focus areas
module FocusAreasHelper
  def focus_area_color(focus_area)
    return focus_area.color if focus_area.color.present?

    position = focus_area.position.present? ? focus_area.position - 1 : 0

    "##{%w[FD6E77 FADD83 FEA785 AFBFF5 84ACD4 74C4DF 71B9B9 7AE0CC 7FD4A0][position]}"
  end
end
