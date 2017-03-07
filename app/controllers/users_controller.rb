class UsersController < ApplicationController
  before_action :authenticate_user!

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = policy_scope(User).page params[:page]
  end

  def show
  end

  def new
    @user = User.new
    authorize @user
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    authorize @user
        
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
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
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
      authorize @user
    end

    def user_params
      params.fetch(:user, {}).permit(
        :name,
        :email,
        accounts_users_attributes: [:account_id, :account_role]
      )
    end
end
