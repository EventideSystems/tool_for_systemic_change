class EcosystemMaps::OrganisationsController < ApplicationController
  before_action :set_scorecard
  after_action :verify_authorized, except: :show

  layout :false

  def show
    @organisation = @scorecard.organisations.find(params[:id])

    initiatives = @scorecard
      .initiatives_organisations
      .where(organisation: @organisation)
      .map(&:initiative)
      .uniq

    @partnering_organisations = InitiativesOrganisation
      .where(initiative: initiatives)
      .where.not(organisation: @organisation)
      .joins(:organisation)
      .map(&:organisation)
      .uniq
    
    @partnering_initiatives = InitiativesOrganisation
      .where(initiative: initiatives)
      .where(organisation: @partnering_organisations)
      .joins(:initiative)
      .map(&:initiative)
      .uniq

    @connections = @partnering_organisations.count

    @weighted_connections = InitiativesOrganisation
      .where(initiative: initiatives)
      .where(organisation: @partnering_organisations)
      .count

    @betweenness = params[:betweenness].to_d.round(6)
  end

  private

  def set_scorecard
    @scorecard = Scorecard.find(params[:ecosystem_map_id])
  end
end
