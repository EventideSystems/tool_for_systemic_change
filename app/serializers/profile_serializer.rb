class ProfileSerializer < ActiveModel::Serializer
  attributes :user_email, :user_role, :user_name, :administrating_organisation_name
end
