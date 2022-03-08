# frozen_string_literal: true

class UpdateFocusAreaColors < ActiveRecord::Migration[6.1]
  def up
    FocusArea.where.not(actual_color: nil).each do |focus_area|
      focus_area.update(planned_color: lighten_color(focus_area.actual_color))
    end
  end

  def down
    # NO OP
  end

  private

  # Source: https://www.redguava.com.au/2011/10/lighten-or-darken-a-hexadecimal-color-in-ruby-on-rails/
  def lighten_color(hex_color, amount = 0.3)
    hex_color = hex_color.gsub('#', '')
    rgb = hex_color.scan(/../).map(&:hex)
    rgb[0] = [(rgb[0].to_i + (255 * amount)).round, 255].min
    rgb[1] = [(rgb[1].to_i + (255 * amount)).round, 255].min
    rgb[2] = [(rgb[2].to_i + (255 * amount)).round, 255].min
    '#%02x%02x%02x' % rgb
  end
end
