# frozen_string_literal: true

module EcosystemMaps
  # Controller for Organisations used by EcosystemMaps
  class OrganisationsController < ApplicationController
    before_action :set_scorecard
    after_action :verify_authorized, except: :show
    skip_before_action :authenticate_user!, only: %i[show]

    layout false

    def show # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
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

      @initiatives = if @partnering_initiatives.present?
                       []
                     else
                       initiatives
                     end

      @connections = @partnering_organisations.count

      @weighted_connections = InitiativesOrganisation
                              .where(initiative: initiatives)
                              .where(organisation: @partnering_organisations)
                              .count

      @betweenness = params[:betweenness].to_d.round(10)
    end

    private

    def set_scorecard
      if params[:ecosystem_map_id].to_i.to_s == params[:ecosystem_map_id]
        @scorecard = current_account.scorecards.find(params[:ecosystem_map_id])
        authorize @scorecard
      else
        @scorecard = Scorecard.find_by(shared_link_id: params[:ecosystem_map_id])
      end
    end
  end
end
