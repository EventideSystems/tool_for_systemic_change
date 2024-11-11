# frozen_string_literal: true

# Controller for ChecklistItems
class ChecklistItemsController < ApplicationController
  include VerifyPolicies

  def show
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item

    render json: @checklist_item.to_json(only: %i[id status comment humanized_status])
  end

  def edit
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item
  end

  def update # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item

    @checklist_item.assign_attributes(checklist_item_params)

    build_checklist_item_changes(params, @checklist_item) if @checklist_item.changed?

    @checklist_item.user = current_user if @checklist_item.user.nil?

    if @checklist_item.save
      respond_to do |format|
        format.html { redirect_to impact_card_initiative_path(@checklist_item.scorecard, @checklist_item.initiative) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def build_checklist_item_changes(params, checklist_item)
    checklist_item.checklist_item_changes.build(
      user: current_user,
      starting_status: checklist_item.status_was,
      ending_status: checklist_item.status,
      comment: checklist_item.comment,
      action: params[:action],
      activity: checklist_item_activity(params, checklist_item)
    )
  end

  def checklist_item_activity(params, checklist_item)
    if new_comments_saved_assigned_actuals?(params, checklist_item)
      'new_comments_saved_assigned_actuals'
    else
      checklist_item.status_was != 'actual' && checklist_item.status == 'actual' ? 'addition' : 'none'
    end
  end

  def checklist_item_params # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    if params[:checklist_item][:new_comment].present?
      params[:checklist_item][:comment] =
        params[:checklist_item][:new_comment]
    end
    if params[:checklist_item][:new_status].present?
      params[:checklist_item][:status] =
        params[:checklist_item][:new_status]
    end

    if params[:action] == 'save_new_comment'
      params[:checklist_item][:comment] = nil if params[:checklist_item][:comment].blank?
      params[:checklist_item][:status] = nil if params[:checklist_item][:status].blank?
    end

    params.require(:checklist_item).permit(:status, :comment)
  end

  def new_comments_saved_assigned_actuals?(params, checklist_item)
    params[:action] == 'save_new_comment' &&
      checklist_item.comment.present? &&
      checklist_item.status_was == 'actual' &&
      checklist_item.status == 'actual'
  end
end
