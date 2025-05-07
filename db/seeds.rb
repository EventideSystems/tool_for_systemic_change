# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


if Rails.env.development?
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

  # Create a workspace admin user
  workspace_admmin_user = User.find_or_create_by!(email: 'admin@obsekio.org') do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.system_role = 'member'
  end

  # Create a default workspace and assign the workspace admin user to it
  Workspace.find_or_create_by!(name: 'Default Workspace') do |workspace|
    workspace.workspaces_users << WorkspacesUser.new(user: user, workspace_role: 'member')
    workspace.workspaces_users << WorkspacesUser.new(user: workspace_admmin_user, workspace_role: 'admin')
    workspace.save!
  end
end

# Create system impact card data models

sdgs_goals_and_targets = DataModel.where(public_model: true).find_by(name: 'SDGs Goals and Targets') 

if sdgs_goals_and_targets.nil?
  sdgs_goals_and_targets = DataModel.create!(
    name: 'SDGs Goals and Targets',
    short_name: 'SDGs',
    description: 'Sustainable Development Goals (SDGs), tracking only Goals and Targets (not Indicators)',
    public_model: true,
    status: :active
  ).tap do |model|
    model.focus_area_groups.create!(
      name: 'SDGs',
      description: 'Sustainable Development Goals (SDGs)',
      position: 1,
      focus_areas_attributes: [
        {
          code: '1'
          name: 'End poverty in all its forms everywhere',
          description: '',
          position: 1,
          
  end
end
