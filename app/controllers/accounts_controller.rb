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

    if @account.save
      redirect_to accounts_path, notice: 'Account was successfully created.'
    else
      render :new
    end
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: 'Account was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_url, notice: 'Account was successfully deleted.'
  end

  def switch
    self.current_account = @account
    redirect_to dashboard_path, notice: 'Account successfully switched.'
  end

  def content_subtitle
    @account&.name.presence || super
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
      :stakeholder_type_id,
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
