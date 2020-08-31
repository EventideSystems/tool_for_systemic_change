class EcosystemMaps::InitiativesController < ApplicationController
  before_action :set_scorecard
  after_action :verify_authorized, except: :show

  layout :false

  def show
    @initiative = @scorecard.initiatives.find(params[:id])

    @partnering_organisations = @scorecard
      .initiatives_organisations
      .where(initiative: @initiative)
      .joins(:organisation)
      .map(&:organisation)
      .uniq

    @subsystem_tags = @initiative.subsystem_tags
  end
  private

  def set_scorecard
    @scorecard = Scorecard.find(params[:ecosystem_map_id])
  end
end
