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

  SDG_COLORS = %w[
    #E5243B
    #DDA63A
    #4C9F38
    #C5192D
    #FF3A21
    #26BDE2
    #FCC30B
    #A21942
    #FD6925
    #DD1367
    #FD9D24
    #BF8B2E
    #3F7E44
    #0A97D9
    #56C02B
    #00689D
    #19486A
  ].freeze

  def option_for_base_color
    SDG_COLORS.map { |color| [color, color] }
  end
end
