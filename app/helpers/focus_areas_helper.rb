module FocusAreasHelper

  def focus_area_icon(focus_area)
    image_tag('sdg_icons/' + focus_area.icon_name, class: 'focus-area-icon')
  end
end
