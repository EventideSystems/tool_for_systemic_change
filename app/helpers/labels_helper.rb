# frozen_string_literal: true

module LabelsHelper

  # Source: https://www.redguava.com.au/2011/10/lighten-or-darken-a-hexadecimal-color-in-ruby-on-rails/

  # Amount should be a decimal between 0 and 1. Lower means darker
  def darken_color(hex_color, amount=0.4)
    hex_color = hex_color.gsub('#','')
    rgb = hex_color.scan(/../).map {|color| color.hex}
    rgb[0] = (rgb[0].to_i * amount).round
    rgb[1] = (rgb[1].to_i * amount).round
    rgb[2] = (rgb[2].to_i * amount).round
    "#%02x%02x%02x" % rgb
  end

  # Amount should be a decimal between 0 and 1. Higher means lighter
  def lighten_color(hex_color, amount=0.6)
    hex_color = hex_color.gsub('#','')
    rgb = hex_color.scan(/../).map {|color| color.hex}
    rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
    rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
    rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
    "#%02x%02x%02x" % rgb
  end

  def contrasting_text_color(hex_color)
    color = hex_color.gsub('#','')
    convert_to_brightness_value(color) > 382.5 ? darken_color(color) : lighten_color(color)
  end

  def convert_to_brightness_value(hex_color)
     (hex_color.scan(/../).map {|color| color.hex}).sum
  end


  def hex_to_rgb(hex)
    hex = hex.gsub('#', '')
    r = hex[0..1].to_i(16)
    g = hex[2..3].to_i(16)
    b = hex[4..5].to_i(16)
    [r, g, b]
  end

  def calculate_luminance(hex_color)
    r, g, b = hex_to_rgb(hex_color)

    # Convert RGB to sRGB
    r = r / 255.0
    g = g / 255.0
    b = b / 255.0

    # Apply gamma correction
    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055) ** 2.4
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055) ** 2.4
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055) ** 2.4

    # Calculate luminance
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    luminance
  end
end
