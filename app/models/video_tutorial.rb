class VideoTutorial < ActiveRecord::Base
  belongs_to :linked, polymorphic: true

  def vimeo_id
    return '' if link_url.blank?

    matches = /https:\/\/vimeo\.com\/(.*)$/.match(link_url)
    matches[1]
  end

  def linked_name
    return '' unless linked.present?

    linked.name
  end

end
