require 'csv'

class OrganisationsController < ApplicationController
  include VerifyPolicies

  before_action :set_organisation, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]

  # add_breadcrumb "Organisations", :organisations_path

  respond_to :js, :html

  sidebar_item :stakeholders

  def index
    respond_to do |format|
      format.html do
        @pagy, @organisations = pagy_countless(policy_scope(Organisation).includes(:stakeholder_type).order(sort_order))
      end

      format.turbo_stream do
        @pagy, @organisations = pagy_countless(policy_scope(Organisation).includes(:stakeholder_type).order(sort_order))
      end

      format.csv do
        @organisations = policy_scope(Organisation).includes(:stakeholder_type).order(sort_order).all
        send_data organisations_to_csv(@organisations, params[:include_stakeholder_list]), :type => Mime[:csv], :filename =>"#{export_filename}.csv"
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
    # add_breadcrumb @organisation.name
  end

  def new
    @organisation = current_account.organisations.build
    authorize @organisation
    # add_breadcrumb "New"
  end

  def edit
    # add_breadcrumb @organisation.name
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

  def organisations_to_csv(organisations, include_stakeholder_list)
    stakeholder_types = current_account.stakeholder_types.order(name: :desc).pluck(:name)

    CSV.generate(force_quotes: true) do |csv|
      header_row = ["Name", "Description", "Stakeholder Type", "Weblink"].tap do |header|
        if include_stakeholder_list
          header.push('')
          header.push('Stakeholder type list - add one to each organisation')
        end
      end

      csv << header_row
      organisations.each do |organisation|
        row_data = [
          organisation.name,
          organisation.description,
          organisation.stakeholder_type&.name,
          organisation.weblink,
        ].tap do |row|
          if include_stakeholder_list
            row.push('')
            row.push(stakeholder_types.pop)
          end
        end

        csv << row_data
      end

      if include_stakeholder_list && stakeholder_types.present?
        stakeholder_types.each do |stakeholder_type|
          csv << ['', '', '', '', '', stakeholder_type]
        end
      end
    end
  end
end
