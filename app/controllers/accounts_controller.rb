class AccountsController < ApplicationController

  before_action :set_account, only: [:show, :edit, :update, :destroy, :switch]

  def index
    @accounts = policy_scope(Account)
  end

  def show
  end

  def new
    @account = Account.new
  end

  def edit
  end

  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def switch
    self.current_account = @account
    respond_to do |format|
      format.html { redirect_back(fallback_location: dashboard_path, notice: 'Account successfully switched.') }
      format.json { render :show, status: :ok, location: @wicked_problem }
    end    
  end

  private

    def set_account
      @account = policy_scope(Account).find(params[:id])
      authorize @account
    end

    def account_params
      params.fetch(:account, {})
    end
end
