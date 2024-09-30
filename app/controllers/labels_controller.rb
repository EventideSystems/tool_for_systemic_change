# frozen_string_literal: true

# Base class for all label-related controllers.
class LabelsController < ApplicationController
  include VerifyPolicies

  before_action :set_label, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update] # Still in use?

  def index
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(label_klass).order(:name).ransack(search_params[:q])
    labels = @q.result(distinct: true)

    @pagy, @labels = pagy(labels, limit: 10, link_extra: 'data-turbo-frame="labels"')

    respond_to do |format|
      format.html { render 'labels/index', locals: { labels: @labels, label_klass: } }
      format.turbo_stream { render 'labels/index', locals: { labels: @labels, label_klass: } }
      format.css  { render 'labels/index', formats: [:css], locals: { labels: @labels  } }
    end
  end


  def edit
    respond_to do |format|
      format.html { render 'labels/edit' }
      format.turbo_stream { render 'labels/edit' }
    end
  end

  def destroy
    @label.delete

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@label) }
      format.html { redirect_to polymorphic_path(label_klass) }
    end
  end

  private

  def set_label
    @label = label_klass.find_by(id: params[:id], account_id: current_account.id)
    authorize @label
  end

  def label_klass
    # implement in subclass
  end

end
