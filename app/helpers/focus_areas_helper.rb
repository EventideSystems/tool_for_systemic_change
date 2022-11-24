# frozen_string_literal: true

module FocusAreasHelper
  def focus_area_icon(focus_area)
    image_tag("sdg_icons/#{focus_area.icon_name}", class: 'focus-area-icon')
  end

  def options_for_icon_name
    Dir.glob(Rails.root.join('app/assets/images/sdg_icons/E-WEB-Goal-*.png')).map do |path|
      [path.split('/').last, path.split('/').last]
    end.sort
  end
end
