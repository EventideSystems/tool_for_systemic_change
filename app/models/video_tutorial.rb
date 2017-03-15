# frozen_string_literal: true
class VideoTutorial < ApplicationRecord
  acts_as_paranoid

  belongs_to :linked, polymorphic: true
  
  scope :promoted_to_dashboard, -> {
    where(promote_to_dashboard: true).order(:position)
  }

  def linked_name
    return '' unless linked.present?

    linked.name
  end
  
  def thumbnail_iframe(height=90, width=90)
    link_url.gsub(/height="(\d*)"/, "height=\"#{height}\"").gsub(/width="(\d*)"/, "width=\"#{width}\"").html_safe  
  end
  
  def iframe(height=380, width=570)
    link_url.gsub(/height="(\d*)"/, "height=\"#{height}\"").gsub(/width="(\d*)"/, "width=\"#{width}\"").html_safe  
  end

  def iframe_width
    return nil unless link_url.present?
    matches = link_url.match(/width="(\d.)"/)
    return matches[1].to_i if matches && matches[1]
    nil
  end
  
  def iframe_height
    return nil unless link_url.present?
    matches = link_url.match(/height="(\d.)"/)
    return matches[1].to_i if matches && matches[1]
    nil
  end
end