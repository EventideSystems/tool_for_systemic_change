# frozen_string_literal: true
class VideoTutorial < ApplicationRecord
  acts_as_paranoid

  belongs_to :linked, polymorphic: true

  def linked_name
    return '' unless linked.present?

    linked.name
  end
end
