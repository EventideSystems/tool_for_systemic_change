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

Given('I am an admin user for the {string} workspace') do |workspace_name|
  workspace = Workspace.find_by(name: workspace_name)
  @user = User.find_by(email: 'workspace-admin@obsek.io')

  if @user.nil?
    @user_password = 'password'
    @user = create(
      :user,
      system_role: :member,
      email: 'workspace-admin@obsek.io',
      password: @user_password,
      password_confirmation: @user_password,
      name: 'Workspace Admin'
    )
  end

  workspace.add_user(@user, :admin)
end
