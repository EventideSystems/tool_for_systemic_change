# frozen_string_literal: true

# Base class for all label-related controllers.
class LabelsController < ApplicationController
  include VerifyPolicies

  before_action :load_label, only: %i[edit update destroy]
  before_action :load_all_labels
  before_action :require_workspace_selected, only: %i[new create edit update] # Still in use?

  def index # rubocop:disable Metrics/AbcSize
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(label_klass).order(:name).ransack(search_params[:q])
    labels = @q.result(distinct: true)

    @pagy, @labels = pagy(labels, limit: 10, link_extra: 'data-turbo-frame="labels"')

    respond_to do |format|
      format.html { render 'labels/index', locals: { labels: @labels, label_klass: } }
      format.turbo_stream { render 'labels/index', locals: { labels: @labels, label_klass: } }
      format.css { render 'labels/index', formats: [:css], locals: { labels: @labels } }
      format.csv { render csv: @all_labels, filename: csv_filename(@all_labels) }
    end
  end

  def new
    @label = label_klass.build(workspace_id: current_workspace.id)
    authorize @label

    respond_to do |format|
      format.html { render 'labels/new' }
      format.turbo_stream { render 'labels/new' }
    end
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @label = label_klass.build(label_params.merge(workspace_id: current_workspace.id))
    authorize @label

    respond_to do |format|
      if @label.save
        @labels = policy_scope(WickedProblem).all
        format.turbo_stream { render 'labels/create', locals: { label: @label } }
        format.html do
          redirect_to label_index_path, notice: "#{label_klass.name.titleize} was successfully created."
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('new_label_form', partial: 'labels/form', locals: { label: @label })
        end
        format.html { render 'labels/new' }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html { render 'labels/edit' }
      format.turbo_stream { render 'labels/edit' }
    end
  end

  def update
    if @label.update(label_params)
      respond_to do |format|
        format.turbo_stream { render 'labels/update', locals: { label: @label } }
        format.html do
          redirect_to label_index_path, notice: "#{label_klass.name.titleize} was successfully updated."
        end
      end
    else
      render 'labels/edit'
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

  def csv_filename(labels)
    "#{labels.model_name.human.pluralize.downcase.tr('/', '-')}-#{Time.zone.now.to_date}"
  end

  def load_all_labels
    @all_labels = policy_scope(label_klass).order('lower(name)')
  end

  def load_label
    @label = label_klass.find_by(id: params[:id], workspace_id: current_workspace.id)
    authorize @label
  end

  def label_klass
    # implement in subclass
  end

  def label_index_path
    # implement in subclass
  end
end
