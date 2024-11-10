# frozen_string_literal: true

# Controller for InitiativesOrganisations, used by the ImpactCard creation form
class InitiativesOrganisationsController < ApplicationController
  def new
    @initiatives_organisation = InitiativesOrganisation.new
    respond_to do |format|
      format.turbo_stream do
        render 'initiatives_organisations/initiatives_organisation',
               locals: { initiatives_organisation: @initiatives_organisation }
      end
    end
  end

  def destroy
    @initiatives_organisation = InitiativesOrganisation.find(params[:id])
    @initiatives_organisation.destroy
  rescue ActiveRecord::RecordNotFound
    @initiatives_organisation = InitiativesOrganisation.new(id: params[:id])
  ensure
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@initiatives_organisation) }
    end
  end
end
