# frozen_string_literal: true

# == Schema Information
#
# Table name: video_tutorials
#
#  id                   :integer          not null, primary key
#  deleted_at           :datetime
#  description          :text
#  link_url             :string
#  linked_type          :string
#  name                 :string
#  position             :integer
#  promote_to_dashboard :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  linked_id            :integer
#
# Indexes
#
#  index_video_tutorials_on_deleted_at                 (deleted_at)
#  index_video_tutorials_on_linked_type_and_linked_id  (linked_type,linked_id)
#
class VideoTutorial < ApplicationRecord
  acts_as_paranoid

  belongs_to :linked, polymorphic: true, optional: true

  scope :promoted_to_dashboard,
        lambda {
          where(promote_to_dashboard: true).order(:position)
        }

  # TODO: Validation based on video link format
  def linked_name
    return '' if linked.blank?

    linked.name
  end

  def thumbnail_iframe(height = 90, width = 90)
    build_vimeo_iframe(vimeo_id_from_link(link_url), height, width)
  end

  def iframe(height = 380, width = 570)
    build_vimeo_iframe(vimeo_id_from_link(link_url), height, width)
  end

  private

  def vimeo_id_from_link(url)
    return '' if url.blank?

    matches = url.match(%r{(/\d+\z)|(/\d+)/?.+?\z})
    matches[matches.length - 1] || matches[0]
  end

  def build_vimeo_iframe(video_id, height, width)
    "<iframe src=\"https://player.vimeo.com/video#{video_id}\" width=\"#{width}\" height=\"#{height}\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>".html_safe
  end
end
