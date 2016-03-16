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

    trackable_object = if self.trackable
      self.trackable
    else
      # Assume deleted, see if we can retrieve from "paranoia"
      deleted_object_class = self.trackable_type.constantize
      if deleted_object_class < ActiveRecord::Base
        deleted_object_class.with_deleted.where(id: self.trackable_id).first
      else
        nil
      end
    end

    trackable_name = if trackable_object.respond_to?(:name)
      trackable_object.deleted? ? [trackable_object.name, '[DELETED]'].join(' ') : trackable_object.name
    else
      'Deleted object'
    end

    "#{self.trackable_type} '#{trackable_name}' #{past_tense(action)} by #{user_name}"
  end

  private

  def past_tense(action)
    action.last == "e" ? "#{action}d" : "#{action}ed"
  end

end
