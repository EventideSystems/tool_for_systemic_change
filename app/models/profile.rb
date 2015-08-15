class Profile
  attr_reader :user_email
  attr_reader :user_role
  attr_reader :user_name
  attr_reader :administrating_organisation_name

  def initialize(user)
    @user_email = user.email
    @user_role = user.role
    @user_name = user.name
    @administrating_organisation_name = if user.staff?
      ''
    else
      user.administrating_organisation.name
    end
  end
end
