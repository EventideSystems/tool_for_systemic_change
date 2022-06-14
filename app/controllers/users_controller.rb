# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update remove_from_account]
  before_action :set_account_role, only: %i[show edit]

  add_breadcrumb 'Users', :users_path

  def index
    respond_to do |format|
      format.html do |_html|
        @users = policy_scope(User).order(sort_order).page params[:page]
      end
      format.csv do
        @users = policy_scope(User).includes(accounts_users: :account).order(:name).all
        send_data users_to_csv(@users), type: Mime[:csv], filename: 'users.csv'
      end
    end
  end

  def show
    @user.readonly!
    add_breadcrumb @user.display_name
  end

  def new
    @user = User.new
    authorize @user
    add_breadcrumb 'New'
  end

  def edit
    add_breadcrumb @user.display_name
  end

  def create
    @user = User.new(user_params)
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = user_params.delete(:account_role)

    @user.accounts_users.build(account: current_account, role: account_role)

    authorize @user

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    user_params.delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = user_params.delete(:account_role)

    current_account_user = @user.accounts_users.find_by_account_id(current_account.id)

    if current_account_user
      current_account_user.update(account_role: account_role)
    else
      @user.accounts_users.build(account: current_account, account_role: account_role)
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_from_account
    accounts_user = AccountsUser
                    .where(user: @user, account: current_account)
                    .where.not(user: current_user)
                    .first

    respond_to do |format|
      if accounts_user.present? && accounts_user.destroy
        format.html { redirect_to users_url, notice: 'User was successfully removed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to users_url, error: 'User could not be removed.' }
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def content_subtitle
    return @user.display_name if @user.present?

    super
  end

  private

  def set_account_role
    current_account_user = @user.accounts_users.find_by_account_id(current_account.id)
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

  def users_to_csv(users)
    account_ids = policy_scope(Account).all.pluck(:id)

    CSV.generate(force_quotes: true) do |csv|
      csv << [
        'Name',
        'Email',
        'Account name',
        'Date created',
        'Account Expiry date',
        'Systems Role',
        'Account Role',
        'Last logged in date'
      ]

      users.each do |user|
        user.accounts_users.each do |accounts_user|
          next unless account_ids.include?(accounts_user.account_id)

          csv << [
            user.name,
            user.email,
            accounts_user.account.name,
            accounts_user.account.created_at.strftime('%d/%m/%Y'),
            accounts_user.account.expires_on&.strftime('%d/%m/%Y') || '',
            user.system_role.titleize,
            accounts_user.account_role.titleize,
            user.last_sign_in_at&.strftime('%d/%m/%Y') || ''
          ]
        end
      end
    end
  end
end
