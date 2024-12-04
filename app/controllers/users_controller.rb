# frozen_string_literal: true

# Controller for managing users
class UsersController < ApplicationController # rubocop:disable Metrics/ClassLength
  include VerifyPolicies

  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update remove_from_account undelete resend_invitation impersonate]
  before_action :set_account_role, only: %i[show edit]

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

  # TODO: Refactor this so that if a user already exists in the system they are sent an invitation to join the account
  # not created as a new user. This will allow for the user to be added to multiple accounts. Maybe move this to a
  # service object.
  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @user = User.new(user_params)
    # SMELL: Move the user_params to the policy
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = user_params.delete(:account_role)

    if current_account.users.where(email: @user.email).exists?
      redirect_to users_path,
                  alert: "A user with the email '#{user.email}' is already a member of this account."
    elsif current_account.max_users_reached?
      redirect_to users_path, alert: 'You have reached the maximum number of users for this account.'
    else
      @user.accounts_users.build(account: current_account, role: account_role)

      authorize @user

      if @user.save
        redirect_to users_path, notice: 'User was successfully created.'
      else
        render :new
      end
    end
  end

  def update # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = user_params.delete(:account_role)

    current_account_user = @user.accounts_users.find_by(account_id: current_account.id)

    if current_account_user
      current_account_user.update(account_role: account_role)
    else
      @user.accounts_users.build(account: current_account, account_role: account_role)
    end

    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def remove_from_account
    accounts_user = AccountsUser
                    .where(user: @user, account: current_account)
                    .where.not(user: current_user)
                    .first

    if accounts_user.present? && accounts_user.destroy
      redirect_to users_path, notice: 'User was successfully removed.'
    else
      redirect_to users_path, error: 'User could not be removed.'
    end
  end

  def impersonate
    self.current_account = @user.accounts.first
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

  def set_account_role
    current_account_user = @user.accounts_users.find_by(account_id: current_account.id)
    @user.account_role = current_account_user.present? ? current_account_user.account_role : 'member'
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.fetch(:user, {}).permit(
      :name,
      :email,
      :time_zone,
      :account_role,
      :system_role
    )
  end

  # TODO: Consider adding this back in as an 'export' feature
  # def users_to_csv(users)
  #   account_ids = policy_scope(Account).all.pluck(:id)

  #   CSV.generate(force_quotes: true) do |csv|
  #     csv << [
  #       'Name',
  #       'Email',
  #       'Account name',
  #       'Date created',
  #       'Account Expiry date',
  #       'Systems Role',
  #       'Account Role',
  #       'Last logged in date'
  #     ]

  #     users.each do |user|
  #       user.accounts_users.each do |accounts_user|
  #         next unless account_ids.include?(accounts_user.account_id)

  #         csv << [
  #           user.name,
  #           user.email,
  #           accounts_user.account.name,
  #           accounts_user.account.created_at.strftime('%d/%m/%Y'),
  #           accounts_user.account.expires_on&.strftime('%d/%m/%Y') || '',
  #           user.system_role.titleize,
  #           accounts_user.account_role.titleize,
  #           user.last_sign_in_at&.strftime('%d/%m/%Y') || ''
  #         ]
  #       end
  #     end
  #   end
  # end
end
