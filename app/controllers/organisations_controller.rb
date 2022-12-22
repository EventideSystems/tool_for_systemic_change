require 'csv'

class OrganisationsController < ApplicationController
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]

  add_breadcrumb "Organisations", :organisations_path

  respond_to :js, :html

  def index
    respond_to do |format|
      format.html do
        @organisations = policy_scope(Organisation).includes(:stakeholder_type).order(sort_order).page params[:page]
      end
      format.csv do
        @organisations = policy_scope(Organisation).includes(:stakeholder_type).order(sort_order).all
        send_data organisations_to_csv(@organisations), :type => Mime[:csv], :filename =>"#{export_filename}.csv"
      end
      format.xlsx do
        @organisations = policy_scope(Organisation).includes(:stakeholder_type).order(sort_order).all
        send_data @organisations.to_xlsx.read, :type => Mime[:xlsx], :filename =>"#{export_filename}.xlsx"
      end
    end
  end

  def show
    @organisation.readonly!
    render 'show'
    add_breadcrumb @organisation.name
  end

  def new
    @organisation = current_account.organisations.build
    authorize @organisation
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @organisation.name
  end

  def create
    @organisation = current_account.organisations.build(organisation_params)
    authorize @organisation

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to organisations_path, notice: 'Organisation was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    if @organisation.update(organisation_params)
      redirect_to organisations_path, notice: 'Organisation was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @organisation.destroy
    redirect_to organisations_url, notice: 'Organisation was successfully deleted.'
  end

  def content_subtitle
    @organisation&.name.presence || super
  end

  private

  def set_organisation
    @organisation = current_account.organisations.find(params[:id])
    authorize @organisation
  end

  def organisation_params
    params.fetch(:organisation, {}).permit(:name, :description, :weblink, :stakeholder_type_id)
  end

  def export_filename
    "organisations_#{Date.today.strftime('%Y_%m_%d')}"
  end

  def organisations_to_csv(organisations)
    CSV.generate(force_quotes: true) do |csv|
      csv << ["Name", "Description", "Stakeholder Type", "Weblink"]
      organisations.each do |organisation|
        csv << [
          organisation.name,
          organisation.description,
          organisation.stakeholder_type&.name,
          organisation.weblink
        ]
      end
    end
  end
end
