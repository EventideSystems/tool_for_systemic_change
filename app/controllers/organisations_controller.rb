class OrganisationsController < ApplicationController
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update] 

  def index
    @organisations = policy_scope(Organisation)
  end

  def show
  end

  def new
    @organisation = current_account.organisations.build
    authorize @organisation
  end

  def edit
  end

  def create
    @organisation = current_account.organisations.build(organisation_params)
    authorize @organisation

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to @organisation, notice: 'Organisation was successfully created.' }
        format.json { render :show, status: :created, location: @organisation }
        format.js
      else
        format.html { render :new }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @organisation.update(organisation_params)
        format.html { redirect_to @organisation, notice: 'Organisation was successfully updated.' }
        format.json { render :show, status: :ok, location: @organisation }
      else
        format.html { render :edit }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organisation.destroy
    respond_to do |format|
      format.html { redirect_to organisations_url, notice: 'Organisation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_organisation
      @organisation = current_account.organisations.find(params[:id])
      authorize @organisation
    end

    def organisation_params
      params.fetch(:organisation, {}).permit(:name, :description, :weblink, :sector_id)
    end
end
