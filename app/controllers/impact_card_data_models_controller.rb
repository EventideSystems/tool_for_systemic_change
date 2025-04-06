# frozen_string_literal: true

require 'csv'

# Controller for managing impact card data models
class ImpactCardDataModelsController < ApplicationController
  after_action :verify_authorized, except: :index

  sidebar_item :library

  def index # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    base_scope = build_base_scope
    @q = base_scope.order(:name).ransack(search_params[:q])

    impact_card_data_models = @q.result(distinct: true)

    @pagy, @impact_card_data_models = pagy(impact_card_data_models, limit: 10)
    @all_impact_card_data_models = policy_scope(ImpactCardDataModel).order('lower(name)')

    respond_to do |format|
      format.html do
        render 'impact_card_data_models/index', locals: { impact_card_data_models: @impact_card_data_models }
      end
      format.turbo_stream do
        render 'impact_card_data_models/index', locals: { impact_card_data_models: @impact_card_data_models }
      end

      format.css do
        render 'impact_card_data_models/index', formats: [:css],
                                                locals: { impact_card_data_models: @impact_card_data_models }
      end
    end
  end

  def show
    @impact_card_data_model = policy_scope(ImpactCardDataModel).find(params[:id])
    authorize @impact_card_data_model
  end

  def copy_to_current_workspace
    @impact_card_data_model = policy_scope(ImpactCardDataModel).find(params[:id])
    authorize @impact_card_data_model

    new_impact_card_data_model = ImpactCardDataModels::CopyToWorkspace.call(
      data_model: @impact_card_data_model, workspace: current_workspace
    )

    redirect_to impact_card_data_model_path(new_impact_card_data_model),
                notice: 'Data Model copied to current workspace'
  end

  def edit
    @impact_card_data_model = policy_scope(ImpactCardDataModel).find(params[:id])
    authorize @impact_card_data_model
  end

  private

  def build_base_scope # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    filter_params = params.permit(q: %i[current_workspace other_workspaces system_models])

    other_workspaces = current_user.workspaces.where.not(id: current_workspace.id)

    permitted_workspaces = if filter_params.empty? || filter_params.dig(:q, :current_workspace) == '1'
                             [current_workspace]
                           else
                             []
                           end

    permitted_workspaces.concat(other_workspaces) if filter_params.dig(:q, :other_workspaces) == '1'

    base_scope = policy_scope(ImpactCardDataModel)

    base_scope = base_scope.where(workspace: permitted_workspaces)
    if filter_params.dig(:q, :system_models) == '1'
      base_scope.or(ImpactCardDataModel.where(system_model: true))
    else
      base_scope.where(system_model: [false, nil])
    end
  end
end
