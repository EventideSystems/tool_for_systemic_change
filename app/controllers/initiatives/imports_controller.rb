# frozen_string_literal: true

module Initiatives
  # Imports for Initiatives
  class ImportsController < ApplicationController
    before_action :require_account_selected, only: %i[new create edit update] # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :set_initiatives_import, only: %i[show edit update destroy] # rubocop:disable Rails/LexicallyScopedActionFilter

    def new
      @initiatives_import = current_account.initiatives_imports.build(
        card_type: scorecard_type_from_scope(params[:scope])
      )
      authorize @initiatives_import
    end

    def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @initiatives_import = current_account.initiatives_imports.build(
        initiatives_import_params.merge(user: current_user)
      )
      authorize @initiatives_import

      if @initiatives_import.save && @initiatives_import.process(current_account)
        redirect_to initiatives_path, notice: 'Initiative records successfully imported.'
      else
        render :new
      end

      @initiatives_import.destroy
      file_system = Shrine.storages[:cache]
      file_system.clear! { |path| path.mtime < Time.zone.now - 1.hour }
    end

    def update
      if @initiatives_import.update(initiatives_import_params)
        redirect_to @initiatives_import, notice: 'Import was successfully updated.'
      else
        render :edit
      end
    end

    private

    def set_initiatives_import
      @initiatives_import = Initiatives::Import.find(params[:id])
      authorize @initiatives_import
    end

    def initiatives_import_params
      params.fetch(:initiatives_import, {}).permit(:import, :card_type)
    end

    def card_type_from_scope
      params[:scope].split('_').first
    end

    def scorecard_type_from_scope(scope)
      case scope
      when 'transition' then 'TransitionCard'
      when 'sdgs_alignment_cards' then 'SustainableDevelopmentGoalAlignmentCard'
      else
        current_account.default_scorecard_type&.name || 'TransitionCard'
      end
    end
  end
end
