class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :switch]

  add_breadcrumb "Accounts", :accounts_path
  
  def index
    @accounts = policy_scope(Account).order(sort_order).page params[:page]
  end

  def show
    add_breadcrumb @account.name
  end

  def new
    @account = Account.new(expires_on: Date.today+1.year)
    authorize @account
    add_breadcrumb "New Account"
  end

  def edit
    add_breadcrumb @account.name
  end

  def create
    @account = Account.new(account_params)
    authorize @account

    respond_to do |format|
      if @account.save
        format.html { redirect_to accounts_path, notice: 'Account was successfully created.' }
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
        format.html { redirect_to accounts_path, notice: 'Account was successfully updated.' }
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
      format.json { render :show, status: :ok, location: @account }
    end    
  end

  
  protected
  
  def sort_order
    return { created_at: :desc } unless params[:order].present?
    super
  end

  private

    def set_account
      @account = Account.find(params[:id])
      authorize @account
    end

    def account_params
      params.fetch(:account, {}).permit(
        :name,
        :description,
        :weblink,
        :sector_id,
        :welcome_message,
        :deactivated,
        :expires_on,
        :max_users,
        :max_scorecards
      )
    end
end



