# frozen_string_literal: true

class UsersController < ApplicationController
  include VerifyPolicies

  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update remove_from_account]
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
      # format.csv  { send_data(initiatives_to_csv(@initiatives), type: Mime[:csv], filename: "#{export_filename}.csv") }
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

  def create
    @user = User.new(user_params)
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = user_params.delete(:account_role)

    @user.accounts_users.build(account: current_account, role: account_role)

    authorize @user

    if @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def update
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = user_params.delete(:account_role)

    current_account_user = @user.accounts_users.find_by(account_id: current_account.id)

    if current_account_user
      current_account_user.update(account_role: account_role)
    else
      @user.accounts_users.build(account: current_account, account_role: account_role)
    end

    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
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

  def content_subtitle
    @user&.display_name.presence || super
  end

  def stop_impersonating
    stop_impersonating_user

    authorize User
    redirect_to root_path, flash: { notice: 'You are no longer impersonating another user' }
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
      :account_role
    )
  end
end
