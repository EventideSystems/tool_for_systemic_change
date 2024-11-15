# frozen_string_literal: true

require 'csv'

# Controller for managing organisations (aka 'stakeholders')
class OrganisationsController < ApplicationController
  include VerifyPolicies

  before_action :set_organisation, only: %i[show edit update destroy]
  before_action :require_account_selected, only: %i[new create edit update]

  respond_to :js, :html

  sidebar_item :stakeholders

  def index
    @stakeholder_types = current_account.stakeholder_types

    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(Organisation).order(:name).ransack(search_params[:q])

    organisations = @q.result(distinct: true)

    @pagy, @organisations = pagy(organisations, limit: 10)

    respond_to do |format|
      format.html { render 'organisations/index', locals: { organisations: @organisations } }
      format.turbo_stream { render 'organisations/index', locals: { organisations: @organisations } }
    end
  end

  def show
    @organisation.readonly!
    render 'show'
  end

  def new
    @organisation = current_account.organisations.build
    authorize @organisation
  end

  def edit; end

  def create
    @organisation = current_account.organisations.build(organisation_params)
    authorize @organisation

    if @organisation.save
      redirect_to edit_organisation_path(@organisation), notice: 'Stakeholder was successfully created.'
    else
      render :new
    end
  end

  def update
    if @organisation.update(organisation_params)
      redirect_to edit_organisation_path(@organisation), notice: 'Stakeholder was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @organisation.destroy
    redirect_to organisations_url, notice: 'Stakeholder was successfully deleted.'
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
    "organisations_#{Time.zone.today.strftime('%Y_%m_%d')}"
  end

  def organisations_to_csv(organisations, include_stakeholder_list) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    stakeholder_types = current_account.stakeholder_types.order(name: :desc).pluck(:name)

    CSV.generate(force_quotes: true) do |csv| # rubocop:disable Metrics/BlockLength
      header_row = ['Name', 'Description', 'Stakeholder Type', 'Weblink'].tap do |header|
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
          organisation.weblink
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
