# frozen_string_literal: true

# Controller for managing User Invitations
class InvitationsController < Devise::InvitationsController
  layout 'application', only: [:new] # NOTE: Defaults to 'devise' layout for other actions

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
    params[:user].delete(:initial_system_role) unless policy(User).invite_with_system_role?
    workspace_role = params[:user].delete(:initial_workspace_role)

    user = User.find_by(email: params[:user][:email])

    if user
      if current_workspace.users.include?(user)
        redirect_to users_path, alert: "A user with the email '#{user.email}' is already a member of this workspace."
      elsif current_workspace.max_users_reached?
        redirect_to users_path, alert: 'You have reached the maximum number of users for this workspace.'
      else
        WorkspacesUser.create!(user: user, workspace: current_workspace, workspace_role: workspace_role)
        redirect_to users_path, notice: 'User was successfully invited.'
      end
    elsif current_workspace.max_users_reached?
      redirect_to users_path, alert: 'You have reached the maximum number of users for this workspace.'
    else
      super do |resource|
        if resource.errors.empty?
          WorkspacesUser.create!(user: resource, workspace: current_workspace, workspace_role: workspace_role)
        end
      end
    end
  end

  def new
    self.resource = resource_class.new
    authorize resource
    render :new
  end
end
