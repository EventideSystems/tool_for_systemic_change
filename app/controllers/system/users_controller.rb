# frozen_string_literal: true

module System
  class UsersController < ApplicationController
    include SharedUserActions
    include VerifyPolicies

    before_action :authenticate_user!
    before_action :set_user, only: %i[show edit update destroy undelete resend_invitation]

    skip_after_action :verify_policy_scoped

    def index
      respond_to do |format|
        format.html do |_html|
          @users = UserPolicy::SystemScope.new(pundit_user, User.all).resolve.page params[:page]
        end
        format.csv do
          @users = @users = UserPolicy::SystemScope.new(pundit_user, User.all).resolve
          send_data users_to_csv(@users), type: Mime[:csv], filename: 'users.csv'
        end
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

      if current_account.users.where(email: @user.email).exists?
        redirect_to system_users_path,
                    alert: "A user with the email '#{user.email}' is already a member of this account."
      elsif max_users_reached?
        redirect_to users_path, alert: 'You have reached the maximum number of users for this account.'
      else
        @user.accounts_users.build(account: current_account, role: account_role)

        authorize @user

        if @user.save
          redirect_to system_users_path, notice: 'User was successfully created.'
        else
          render :new
        end
      end
    end

    def update
      user_params.delete(:system_role) unless policy(User).invite_with_system_role?
      account_role = user_params.delete(:account_role)

      current_account_user = @user.accounts_users.find_by(account_id: current_account.id)

      if current_account_user
        current_account_user.update(account_role: account_role)
      elsif max_users_reached?
        redirect_to users_path, alert: 'You have reached the maximum number of users for this account.' and return
      else
        @user.accounts_users.build(account: current_account, account_role: account_role)
      end

      if @user.update(user_params)
        redirect_to system_users_path, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to system_users_url, notice: 'User was successfully deleted.'
    end

    def impersonate
      user = User.find(params[:id])
      authorize user

      self.current_account = user.accounts.first
      impersonate_user(user)

      redirect_to root_path, flash: { notice: user_impersonation_flash_message }
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to root_path, flash: { notice: 'You are no longer impersonating another user' }
    end

    private

    # SMELL: This is a duplicate of the code in the InvitationsContoller class.
    def max_users_reached?
      return false if current_account.max_users.zero? || current_account.max_users.blank?

      current_account.users.count >= current_account.max_users
    end

    def set_account_role
      current_account_user = @user.accounts_users.find_by(account_id: current_account.id)
      @user.account_role = current_account_user.present? ? current_account_user.account_role : 'member'
    end

    def set_user
      @user = User.with_deleted.find(params[:id])
      authorize @user
    end

    def user_params
      params.fetch(:user, {}).permit(
        :name,
        :email,
        :system_role,
        accounts_users_attributes: %i[id account_role _destroy]
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

    def user_impersonation_flash_message
      "You are now impersonating #{current_user.name}."
    end
  end
end
