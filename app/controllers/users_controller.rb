# frozen_string_literal: true

# Controller for managing users
class UsersController < ApplicationController # rubocop:disable Metrics/ClassLength
  include VerifyPolicies

  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update remove_from_workspace undelete resend_invitation impersonate]
  before_action :set_workspace_role, only: %i[show edit]

  sidebar_item :teams

  def index
    search_params = params.permit(:format, :page, q: [:name_or_email_cont])

    @q = policy_scope(User).order(:name).ransack(search_params[:q])

    users = @q.result(distinct: true)

    @pagy, @users = pagy(users, limit: 10)

    respond_to do |format|
      format.html { render 'users/index', locals: { scorecards: @users } }
      format.turbo_stream { render 'users/index', locals: { scorecards: @users } }
    end
  end

  def show
    @user.readonly!
  end

  def new
    @user = User.new
    authorize @user
  end

  def edit; end

  # TODO: Refactor this so that if a user already exists in the system they are sent an invitation to join the workspace
  # not created as a new user. This will allow for the user to be added to multiple workspaces. Maybe move this to a
  # service object.
  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @user = User.new(user_params)
    # SMELL: Move the user_params to the policy
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    workspace_role = user_params.delete(:workspace_role)

    if current_workspace.users.where(email: @user.email).exists?
      redirect_to users_path,
                  alert: "A user with the email '#{user.email}' is already a member of this workspace."
    elsif current_workspace.max_users_reached?
      redirect_to users_path, alert: 'You have reached the maximum number of users for this workspace.'
    else
      @user.workspaces_users.build(workspace: current_workspace, role: workspace_role)

      authorize @user

      if @user.save
        redirect_to users_path, notice: 'User was successfully created.'
      else
        render :new
      end
    end
  end

  def update
    update_system_role!(@user, user_params)
    update_workspace_role!(@user, user_params)

    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def remove_from_workspace
    workspaces_user = WorkspacesUser
                      .where(user: @user, workspace: current_workspace)
                      .where.not(user: current_user)
                      .first

    if workspaces_user.present? && workspaces_user.destroy
      redirect_to users_path, notice: 'User was successfully removed.'
    else
      redirect_to users_path, error: 'User could not be removed.'
    end
  end

  def impersonate
    self.current_workspace = @user.workspaces.first
    impersonate_user(@user)

    redirect_to root_path, flash: { notice: "You are now impersonating #{current_user.name}." }
  end

  def stop_impersonating
    stop_impersonating_user

    authorize User
    redirect_to root_path, flash: { notice: 'You are no longer impersonating another user' }
  end

  def undelete
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully undeleted.' }
      format.json { head :no_content }
    end
  end

  def resend_invitation
    @user.invite!(current_user)

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was resent invitation.' }
      format.json { head :no_content }
    end
  end

  private

  def set_workspace_role
    current_workspace_user = @user.workspaces_users.find_by(workspace_id: current_workspace.id)
    @user.workspace_role = current_workspace_user.present? ? current_workspace_user.workspace_role : 'member'
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def update_system_role!(user, user_params)
    system_role = user_params.delete(:system_role)

    return unless system_role.present? && policy(user).invite_with_system_role?

    user.update(system_role:)
  end

  def update_workspace_role!(user, user_params)
    workspace_role = user_params.delete(:workspace_role)

    return unless workspace_role.present? && policy(user).change_workspace_role?

    current_workspace_user = user.workspaces_users.find_by(workspace_id: current_workspace.id)

    if current_workspace_user
      current_workspace_user.update(workspace_role: workspace_role)
    else
      user.workspaces_users.build(workspace: current_workspace, workspace_role: workspace_role)
    end
  end

  def user_params # rubocop:disable Metrics/MethodLength
    params.fetch(:user, {}).permit(
      :name,
      :email,
      :time_zone,
      :workspace_role,
      :system_role,
      :password,
      :password_confirmation
    ).then do |permitted_params|
      permitted_params.delete(:password) if params[:user][:password].blank?
      permitted_params.delete(:password_confirmation) if params[:user][:password].blank?

      permitted_params
    end
  end

  # TODO: Consider adding this back in as an 'export' feature
  # def users_to_csv(users)
  #   workspace_ids = policy_scope(workspace).all.pluck(:id)

  #   CSV.generate(force_quotes: true) do |csv|
  #     csv << [
  #       'Name',
  #       'Email',
  #       'workspace name',
  #       'Date created',
  #       'workspace Expiry date',
  #       'Systems Role',
  #       'workspace Role',
  #       'Last logged in date'
  #     ]

  #     users.each do |user|
  #       user.workspaces_users.each do |workspaces_user|
  #         next unless workspace_ids.include?(workspaces_user.workspace_id)

  #         csv << [
  #           user.name,
  #           user.email,
  #           workspaces_user.workspace.name,
  #           workspaces_user.workspace.created_at.strftime('%d/%m/%Y'),
  #           workspaces_user.workspace.expires_on&.strftime('%d/%m/%Y') || '',
  #           user.system_role.titleize,
  #           workspaces_user.workspace_role.titleize,
  #           user.last_sign_in_at&.strftime('%d/%m/%Y') || ''
  #         ]
  #       end
  #     end
  #   end
  # end
end
