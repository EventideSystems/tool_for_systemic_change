# frozen_string_literal: true

require 'csv'

# Controller for managing organisations (aka 'stakeholders')
class ImpactCardDataModelsController < ApplicationController
  include VerifyPolicies

  # before_action :set_organisation, only: %i[show edit update destroy]
  # before_action :require_workspace_selected, only: %i[new create edit update]

  # respond_to :js, :html

  sidebar_item :library

  def index # rubocop:disable Metrics/MethodLength
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(ImpactCardDataModel).order(:name).ransack(search_params[:q])

    impact_card_data_models = @q.result(distinct: true)

    @pagy, @impact_card_data_models = pagy(impact_card_data_models, limit: 10)

    respond_to do |format|
      format.html do
        render 'impact_card_data_models/index', locals: { impact_card_data_models: @impact_card_data_models }
      end
      format.turbo_stream do
        render 'impact_card_data_models/index', locals: { impact_card_data_models: @impact_card_data_models }
      end
      # format.csv do
      #   all_impact_card_data_models = current_workspace.impact_card_data_models.order('lower(name)')
      #   send_data(
      #     impact_card_data_models_to_csv(all_impact_card_data_models), filename: "#{export_filename}.csv"
      #   )
      # end
    end
  end
end
