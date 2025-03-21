# frozen_string_literal: true

Given('I am a system admin user') do
  @user_password = 'password'
  @user = create(
    :user,
    system_role: :admin,
    email: 'system-admin@obsek.io',
    password: @user_password,
    password_confirmation: @user_password,
    name: 'System Admin'
  )
end

Given('I am an admin user for the {string} account') do |account_name|
  account = Account.find_by(name: account_name)
  @user = User.find_by(email: 'account-admin@obsek.io')

  if @user.nil?
    @user_password = 'password'
    @user = create(
      :user,
      system_role: :member,
      email: 'account-admin@obsek.io',
      password: @user_password,
      password_confirmation: @user_password,
      name: 'Account Admin'
    )
  end

  account.add_user(@user, :admin)
end
