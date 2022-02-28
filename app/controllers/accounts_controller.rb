# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: %i[show edit update destroy switch]

  add_breadcrumb 'Accounts', :accounts_path

  def index
    @accounts = policy_scope(Account).order(sort_order).page params[:page]
  end

  def show
    @account.readonly!
    add_breadcrumb @account.name
  end

  def new
    @account = Account.new(expires_on: Date.today + 1.year)
    authorize @account
    add_breadcrumb 'New'
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
      format.html { redirect_to dashboard_path, notice: 'Account successfully switched.' }
      format.json { render :show, status: :ok, location: @account }
    end
  end

  def content_subtitle
    return @account.name if @account.present?

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
      :max_scorecards,
      :solution_ecosystem_maps,
      :allow_transition_cards,
      :allow_sustainable_development_goal_alignment_cards
    )
  end
end
