# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# Create a default system admin user
User.find_or_create_by!(email: 'system_admin@obsekio.org') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.system_role = 'admin'
end

# Create a default user

user = User.find_or_create_by!(email: 'user@obsekio.org') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.system_role = 'member'
end

# Create an account admin user
#
account_admmin_user = User.find_or_create_by!(email: 'admin@obsekio.org') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.system_role = 'member'
end

# Create a default account

Account.find_or_create_by!(name: 'Default Account') do |account|
  account.accounts_users << AccountsUser.new(user: user, account_role: 'member')
  account.accounts_users << AccountsUser.new(user: account_admmin_user, account_role: 'admin')
  account.save!
end
