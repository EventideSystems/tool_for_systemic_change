module ActivitiesHelper
  def activity_summary(activity)
    return '' unless activity.present?    
    subject_type, action = *activity.key.split('.')
    subject_name = activity.trackable.nil? ? '[DELETED]' : activity.trackable.name
    actor = activity.owner.is_a?(User) ? "by #{activity.owner.name}" : '' 
    action_past_tense = action == 'destroy' ? 'destroyed' : "#{action}d"
    "#{subject_type.humanize.titleize} '#{subject_name}' #{action_past_tense} #{actor}"
  end
end
