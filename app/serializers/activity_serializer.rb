class ActivitySerializer < BaseSerializer
  attributes :trackable_id, :trackable_type, :owner_id, :owner_type, :key, :action, :created_at

  def action
    matches = /.*\.(.*)$/.match(object.key)
    matches[1] || object.key
  end
end
