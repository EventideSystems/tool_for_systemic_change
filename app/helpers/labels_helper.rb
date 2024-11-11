# frozen_string_literal: true

module LabelsHelper
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
    r /= 255.0
    g /= 255.0
    b /= 255.0

    # Apply gamma correction
    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055)**2.4
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055)**2.4
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055)**2.4

    # Calculate luminance
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end
end
