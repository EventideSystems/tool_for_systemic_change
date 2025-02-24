# frozen_string_literal: true

# NOTE: This is **not** a nested resource, but a separate controller that is used to create
# community records within the context of impact cards.
class ImpactCardsCommunitiesController < ApplicationController
  def index; end

  def new
    @community = current_account.communities.new
    authorize @community
  end

  def create # rubocop:disable Metrics/MethodLength
    @community = current_account.communities.new(community_params)
    authorize @community

    if @community.save
      respond_to do |format|
        format.html
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'new_impact_cards_communities_form',
            partial: 'form',
            locals: { label: @community }
          )
        end
      end
    end
  end

  private

  def community_params
    params.require(:community).permit(:name, :color)
  end
end
