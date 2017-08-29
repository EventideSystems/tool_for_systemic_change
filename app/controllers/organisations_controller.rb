require 'csv'

class OrganisationsController < ApplicationController
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update] 

  add_breadcrumb "Organisations", :organisations_path
  
  def index
    @organisations = policy_scope(Organisation).includes(:sector).order(sort_order).page params[:page]
    
    respond_to do |format|
      format.html
      format.csv do
        send_data organisations_to_csv(@organisations), :type => Mime[:csv], :filename =>"#{export_filename}.csv" 
      end
      format.xlsx do
        send_data @organisations.to_xlsx.read, :type => Mime[:xlsx], :filename =>"#{export_filename}.xlsx" 
      end
    end
  end

  def show
    @organisation.readonly!
    add_breadcrumb @organisation.name
  end

  def new
    @organisation = current_account.organisations.build
    authorize @organisation
    add_breadcrumb "New Organisation"
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
        format.html { redirect_to organisations_path, notice: 'Organisation was successfully updated.' }
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
  
  def content_subtitle
    return @organisation.name if @organisation.present?
    super
  end

  private
    def set_organisation
      @organisation = current_account.organisations.find(params[:id])
      authorize @organisation
    end

    def organisation_params
      params.fetch(:organisation, {}).permit(:name, :description, :weblink, :sector_id)
    end
    
    def export_filename
      "organisations_#{Date.today.strftime('%Y_%m_%d')}"
    end
    
    def organisations_to_csv(organisations)
      CSV.generate(force_quotes: true) do |csv|
       csv << ["Name", "Description", "Sector", "Weblink"]
       organisations.each do |organisation|
         csv << [
           organisation.name,
           organisation.description,
           organisation.sector.try(:name),
           organisation.weblink
         ]
       end
     end
    end
end
