class VideoTutorial < ActiveRecord::Base
  belongs_to :linked, polymorphic: true


  def linked_name
    return '' unless linked.present?

    linked.name
  end

end
