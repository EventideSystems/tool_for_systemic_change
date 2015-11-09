require 'public_activity'

class PublicActivity::Activity

  attr_reader :action
  attr_reader :short_message
  attr_reader :long_message

  def action
    matches = /.*\.(.*)$/.match(self.key)
    matches[1] || self.key
  end

  def short_message
    "#{self.trackable_type} #{action}d"
  end

  def long_message
    user = self.owner
    user_name = user ? user.name : 'Unknown user'
    aaa = trackable.name

    "#{self.trackable_type} '#{self.trackable.name}' #{action}d by #{user_name}"
  end

end
