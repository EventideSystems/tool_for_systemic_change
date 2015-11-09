class ActivitySerializer < BaseSerializer
  attributes :trackable_id, :trackable_type, :owner_id,
    :owner_type, :key, :action, :short_message, :long_message, :created_at
end
