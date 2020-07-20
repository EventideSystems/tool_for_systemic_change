# frozen_string_literal: true
class VideoTutorial < ApplicationRecord
  acts_as_paranoid

  belongs_to :linked, polymorphic: true, optional: true
  
  scope :promoted_to_dashboard, -> {
    where(promote_to_dashboard: true).order(:position)
  }
  
  # TODO Validation based on video link format
  def linked_name
    return '' unless linked.present?

    linked.name
  end
  
  def thumbnail_iframe(height=90, width=90)
    build_vimeo_iframe(vimeo_id_from_link(link_url), height, width)
  end
  
  def iframe(height=380, width=570)
    build_vimeo_iframe(vimeo_id_from_link(link_url), height, width)
  end
  
  private
  
  def vimeo_id_from_link(url)
    matches = url.match(/(\/\d+\z)|(\/\d+)[\/]?.+?\z/)
    matches[matches.length-1] || matches[0]
  end
  
  def build_vimeo_iframe(video_id, height, width)
    "<iframe src=\"https://player.vimeo.com/video#{video_id}\" width=\"#{width}\" height=\"#{height}\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>".html_safe
  end
end
