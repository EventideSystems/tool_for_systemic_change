class ActivitySerializer < BaseSerializer
  attributes :trackable_id, :trackable_type, :owner_id,
    :owner_type, :key, :action, :short_message, :long_message, :created_at

  def action
    matches = /.*\.(.*)$/.match(object.key)
    matches[1] || object.key
  end

  def short_message
    "#{object.trackable_type} #{action}d"
  end

  def long_message
    user = object.owner

    "#{object.trackable_type} '#{object.trackable.name}' #{action}d by #{user.name}"
  end
end
