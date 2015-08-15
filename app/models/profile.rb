class Profile
  attr_reader :user_email
  attr_reader :user_role
  attr_reader :administrating_organisation_name

  def initialize(user)
    @user_email = user.email
    @user_role = user.role
    @administrating_organisation_name = if user.staff?
      ''
    else
      user.administrating_organisation.name
    end
  end
end
