# frozen_string_literal: true

module ScorecardComments
  # Imports for Scorecard Comments
  class ImportsController < ApplicationController
    def new
      @scorecard_comments_import = current_workspace.scorecard_comments_imports.build
      authorize(@scorecard_comments_import)
    end

    def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @scorecard_comments_import = current_workspace.scorecard_comments_imports.build(
        scorecard_comments_import_params.merge(user: current_user)
      )
      authorize(@scorecard_comments_import)

      if @scorecard_comments_import.save && @scorecard_comments_import.process(current_user, current_workspace)
        redirect_to(transition_cards_path, notice: 'Card Comments records successfully imported.')
      else
        render(:new)
      end

      @scorecard_comments_import.destroy
      # file_system = Shrine.storages[:cache]
      file_system.clear! { |path| path.mtime < Time.zone.now - 1.hour }
    end

    def update
      if @scorecard_comments_import.update(scorecard_comments_import_params)
        redirect_to(@scorecard_comments_import, notice: 'Import was successfully updated.')
      else
        render(:edit)
      end
    end

    private

    def set_scorecard_comments_import
      @scorecard_comments_import = ScorecardComments::Import.find(params[:id])
      authorize(@scorecard_comments_import)
    end

    def scorecard_comments_import_params
      params.fetch(:scorecard_comments_import, {}).permit(:import)
    end
  end
end
