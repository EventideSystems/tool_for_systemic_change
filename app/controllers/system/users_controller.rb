module System
  class UsersController < ApplicationController
    
    include SharedUserActions
    
    before_action :authenticate_user!
    before_action :set_user, only: [:show, :edit, :update, :destroy, :undelete, :resend_invitation]

    skip_after_action :verify_policy_scoped
  
    add_breadcrumb "System"
    add_breadcrumb "Users", :system_users_path

    def index
      @users = UserPolicy::SystemScope.new(pundit_user, User.all).resolve.page params[:page]
    end

    def show
      @user.readonly!
      add_breadcrumb @user.display_name
    end

    def new
      @user = User.new
      authorize @user
      add_breadcrumb "New"
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
          format.html { redirect_to system_users_path, notice: 'User was successfully created.' }
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
        current_account_user.update_attributes(account_role: account_role)
      else
        @user.accounts_users.build(account: current_account, account_role: account_role)
      end

      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to system_users_path, notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to system_users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def content_title
      'System Users'
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
      @user = User.with_deleted.find(params[:id])
      authorize @user
    end

    def user_params
      params.fetch(:user, {}).permit(
        :name,
        :email,
        :system_role,
        accounts_users_attributes: [:id, :account_role, :_destroy]
      )
    end
  end
end
