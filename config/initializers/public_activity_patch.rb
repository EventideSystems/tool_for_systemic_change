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
    "#{self.trackable_type} #{past_tense(action)}"
  end

  def long_message
    user = self.owner
    user_name = user ? user.name : 'System user'

    user_name = 'Unknown' if user_name.blank?

    trackable_name = if self.trackable.respond_to?(:name)
      self.trackable.name
    else
      if self.trackable
        self.trackable.id.to_s
      else
        'Deleted object'
      end
    end

    "#{self.trackable_type} '#{trackable_name}' #{past_tense(action)} by #{user_name}"
  end

  private

  def past_tense(action)
    action.last == "e" ? "#{action}d" : "#{action}ed"
  end

end
