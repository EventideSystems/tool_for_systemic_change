# frozen_string_literal: true

# NOTE: This is **not** a nested resource, but a separate controller that is used to create
# organisation (aka stakeholder) records within the context of initiatives.
class InitiativesOrganisationsController < ApplicationController
  # Used to return to base state if cancel is clicked
  def index
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('new_initiatives_organisation',
                                                  partial: '/initiatives_organisations/index')
      end
    end
  end

  def new # rubocop:disable Metrics/MethodLength
    @organisation = current_account.organisations.new
    authorize @organisation

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'new_initiatives_organisation',
          partial: '/initiatives_organisations/form',
          locals: { organisation: @organisation }
        )
      end
    end
  end

  def create # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    @organisation = find_existing_organisation(organisation_params)

    if @organisation.present?
      @organisation.assign_attributes(organisation_params)
    else
      @organisation = current_account.organisations.new(organisation_params)
    end

    authorize @organisation

    if @organisation.save
      respond_to do |format|
        format.html
        format.turbo_stream
      end
    else
      # render 'new'
      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'new_initiatives_organisation',
            partial: '/initiatives/organisations/form',
            locals: { organisation: @organisation }
          )
        end
      end
    end
  end

  private

  def find_existing_organisation(organisation_params)
    current_account.organisations.find_by(name: organisation_params[:name])
  end

  def organisation_params
    params.require(:organisation).permit(:name, :description, :stakeholder_type_id, :weblink)
  end
end
