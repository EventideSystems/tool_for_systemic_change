class UserSerializer < BaseSerializer
  attributes :email, :role, :name, :created_at, :updated_at, :last_sign_in_at

  belongs_to :administrating_organisation
end
