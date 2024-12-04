# frozen_string_literal: true

# Deprecated: This module is a temporary solution until the relationship is fixed, or the video_tutorial
# is removed from the related models.
module HasVideoTutorial
  extend ActiveSupport::Concern

  included do
    attr_accessor :video_tutorial_id

    has_one :video_tutorial, as: :linked, dependent: :destroy

    # SMELL: This is a hack to allow the video_tutorial_id to be set on the
    # characteristic. This is needed because the video_tutorial has been set as a
    # "has_one" relationship, but it actually should be inverted to a "belongs_to"
    # relationship.
    #
    # This is a temporary solution until the relationship is fixed, or the video_tutorial
    # is removed from the characteristic model.
    def video_tutorial_id=(value)
      return if value.blank?

      tutorial = VideoTutorial.where(id: value).first
      tutorial&.update(linked: self)
    end

    # SMELL: See above
    def video_tutorial_id
      video_tutorial.try(:id)
    end
  end
end
