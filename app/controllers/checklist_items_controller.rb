# frozen_string_literal: true

class ChecklistItemsController < ApplicationController

  def show
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item

    render json: @checklist_item.to_json(only: [:id, :status, :comment, :humanized_status])
  end

  def edit
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item

    render partial: 'form', locals: { checklist_item: @checklist_item }
  end

  def update
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item

    @checklist_item.assign_attributes(checklist_item_params)

    if @checklist_item.changed?
      @checklist_item.checklist_item_changes.build(
        user: current_user,
        starting_status: @checklist_item.status_was,
        ending_status: @checklist_item.status,
        comment: @checklist_item.comment,
        action: checklist_item_action(params),
        activity: checklist_item_activity(params, @checklist_item)
      )
    end

    @checklist_item.save

    if @checklist_item.errors.any?
      render json: { errors: @checklist_item.errors.full_messages }, status: :unprocessable_entity
    else
      render json: {}, status: :ok
    end
  end

  private

  def checklist_item_action(params)
    case params[:commit]
    when 'Update Existing'
      'update_existing'
    when 'Save New Comment'
      'save_new_comment'
    end
  end

  def checklist_item_activity(params, checklist_item)
    if new_comments_saved_assigned_actuals?(params, checklist_item)
      'new_comments_saved_assigned_actuals'
    else
      (@checklist_item.status_was != 'actual' && @checklist_item.status == 'actual') ? 'addition' : 'none'
    end
  end

  def checklist_item_params
    params[:checklist_item][:comment] = params[:checklist_item][:new_comment] if params[:checklist_item][:new_comment].present?
    params[:checklist_item][:status] = params[:checklist_item][:new_status] if params[:checklist_item][:new_status].present?

    if params[:commit] == 'Save New Comment'
      params[:checklist_item][:comment] = nil if params[:checklist_item][:comment].blank?
      params[:checklist_item][:status] = nil if params[:checklist_item][:status].blank?
    end

    params.require(:checklist_item).permit(:status, :comment)
  end

  def new_comments_saved_assigned_actuals?(params, checklist_item)
    params[:commit] == 'Save New Comment' &&
      checklist_item.comment.present? &&
      checklist_item.status_was == 'actual' &&
      checklist_item.status == 'actual'
  end
end
