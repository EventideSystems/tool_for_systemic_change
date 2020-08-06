class ScorecardComments::ImportsController < ApplicationController
  
  def new
    @scorecard_comments_import = current_account.scorecard_comments_imports.build
    authorize @scorecard_comments_import
  end
  
  def create
    @scorecard_comments_import = current_account.scorecard_comments_imports.build(
      scorecard_comments_import_params.merge(user: current_user)
    ) 
    authorize @scorecard_comments_import
    
    respond_to do |format|
      if @scorecard_comments_import.save && @scorecard_comments_import.process(current_account)
        format.html { redirect_to scorecards_path, notice: 'Transition Card Comments records successfully imported.' }
        format.json { render :show, status: :created, location: @scorecard_comments_import }
      else
        format.html { render :new }
        format.json { render json: @scorecard_comments_import.errors, status: :unprocessable_entity }
      end
    end
    
    @scorecard_comments_import.destroy
    file_system = Shrine.storages[:cache]
    file_system.clear! { |path| path.mtime < Time.now - 1.hour } 
  end

  def update
    respond_to do |format|
      if @scorecard_comments_import.update(scorecard_comments_import_params)
        format.html { redirect_to @scorecard_comments_import, notice: 'Import was successfully updated.' }
        format.json { render :show, status: :ok, location: @scorecard_comments_import }
      else
        format.html { render :edit }
        format.json { render json: @scorecard_comments_import.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def content_title
    'Transition Card Comments'
  end
  
  def content_subtitle
    'Import'
  end
  
  private
  
  def set_scorecard_comments_import
    @scorecard_comments_import = ScorecardComments::Import.find(params[:id])
    authorize @scorecard_comments_import
  end

  def scorecard_comments_import_params
    params.fetch(:scorecard_comments_import, {}).permit(:import)
  end
end
