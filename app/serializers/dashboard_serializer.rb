class DashboardSerializer < BaseSerializer
  attributes :welcome_message_html, :client_name, :activities, :video_tutorials

  def activities
    object.activities.map do |activity|
      {
        id:             activity.id,
        trackable_id:   activity.trackable_id,
        trackable_type: activity.trackable_type,
        owner_id:       activity.owner_id,
        owner_type:     activity.owner_type,
        key:            activity.key,
        action:         activity.action,
        short_message:  activity.short_message,
        long_message:   activity.long_message,
        created_at:     activity.created_at

      }
    end
  end

  def video_tutorials
    object.video_tutorials.map do |video_tutorial|
      {
        id:             video_tutorial.id,
        name:           video_tutorial.name,
        description:    video_tutorial.description,
        link_url:       video_tutorial.link_url,
        created_at:     video_tutorial.created_at,
        updated_at:     video_tutorial.updated_at
      }
    end
  end
end
