# frozen_string_literal: true

# Controller for managing reports
# rubocop:disable Metrics/ClassLength
class ReportsController < ApplicationController
  sidebar_item :reports

  def index
    authorize(:report, :index?)

    @scorecards = policy_scope(Scorecard).order(:name)
    @grouped_scorecards = @scorecards.group_by do |scorecard|
      scorecard.data_model.name
    end.transform_values do |scorecards| # rubocop:disable Style/MultilineBlockChain
      scorecards.map do |scorecard|
        [scorecard.name, scorecard.id]
      end
    end
  end

  def impact_card_activity # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    authorize(:report, :impact_card_activity?)

    @date_from = ActiveSupport::TimeZone[current_user.time_zone].parse(params[:date_from]).beginning_of_day.utc

    @date_to = ActiveSupport::TimeZone[current_user.time_zone].parse(params[:date_to]).end_of_day.utc

    @date_to = Date.parse(params[:date_to]).end_of_day
    @scorecard = current_workspace.scorecards.find(params[:scorecard_id])

    @report = Reports::ImpactCardActivity.new(@scorecard, @date_from, @date_to)

    respond_to do |format|
      format.xlsx do
        send_data(
          @report.to_xlsx.read,
          type: Mime[:xlsx],
          filename: "#{scorecard_new_activity_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
        )
      end
    end
  end

  def scorecard_comments # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    authorize(:report, :index?)

    @scorecard = current_workspace
                 .scorecards
                 .includes(initiatives: [checklist_items: [characteristic: [focus_area: :focus_area_group]]])
                 .find(params[:scorecard_id])

    @date = ActiveSupport::TimeZone[current_user.time_zone].parse(params[:date]).end_of_day.utc

    @status = params[:status]

    @report = Reports::ScorecardComments.new(@scorecard, @date, @status, current_user.time_zone)

    respond_to do |format|
      format.xlsx do
        send_data(
          @report.to_xlsx.read,
          type: Mime[:xlsx],
          filename: "#{scorecard_new_comments_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx",
          disposition: 'attachment'
        )
      end
    end
  end

  def impact_card_stakeholders
    authorize(:report, :index?)

    @scorecard = current_workspace.scorecards.find(params[:scorecard_id])
    @report = Reports::ImpactCardStakeholders.new(@scorecard)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "#{impact_card_stakeholders_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
    )
  end

  def subsystem_summary
    authorize(:report, :subsystem_summary?)

    @scorecard = current_workspace.scorecards.find(params[:scorecard_id])
    @report = Reports::SubsystemSummary.new(@scorecard)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "#{subsystem_summary_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
    )
  end

  def cross_workspace_percent_actual
    authorize(:report, :cross_workspace_percent_actual?)

    @workspaces = current_user.active_workspaces_with_admin_role
    @report = Reports::CrossWorkspacePercentActual.new(@workspaces)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "Cross_Workspace_Percent_Actual_#{time_stamp_suffix}.xlsx"
    )
  end

  def cross_workspace_percent_actual_by_focus_area
    authorize(:report, :cross_workspace_percent_actual_by_focus_area?)

    @workspaces = current_user.active_workspaces_with_admin_role
    @report = Reports::CrossWorkspacePercentActualByFocusArea.new(@workspaces)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "Cross_Workspace_Percent_Actual_By_Focus_Area_#{time_stamp_suffix}.xlsx"
    )
  end

  def cross_workspace_percent_actual_by_focus_area_tabbed
    authorize(:report, :cross_workspace_percent_actual_by_focus_area_tabbed?)

    @workspaces = current_user.active_workspaces_with_admin_role
    @report = Reports::CrossWorkspacePercentActualByFocusAreaTabbed.new(@workspaces)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "Cross_Workspace_Percent_Actual_By_Focus_Area_Tabbed_#{time_stamp_suffix}.xlsx"
    )
  end

  private

  def scorecard_activity_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_Activity"
  end

  def scorecard_new_activity_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_New_Activity"
  end

  def scorecard_new_comments_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_New_Comments"
  end

  def scorecard_comments_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_Comments"
  end

  def impact_card_stakeholders_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_Stakeholders"
  end

  def subsystem_summary_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_Subsystems"
  end

  def report_filename_prefix(scorecard)
    scorecard.data_model.name.tr(' ', '_')
  end

  def time_stamp_suffix
    Time.zone.now.strftime('_%Y_%m_%d')
  end
end
# rubocop:enable Metrics/ClassLength
