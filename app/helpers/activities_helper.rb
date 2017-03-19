module ActivitiesHelper
  def activity_summary(activity)
    return '' unless activity.present?    
    subject_type, action = *activity.key.split('.')
    subject_name = activity.trackable.name
    actor = activity.owner.is_a?(User) ? "by #{activity.owner.name}" : '' 
    "#{subject_type.humanize.titleize} '#{subject_name}' #{action}d #{actor}"
  end
end
