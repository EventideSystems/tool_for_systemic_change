class DashboardSerializer < BaseSerializer
  attributes :welcome_message_html, :client_name, :activities

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
end
