# frozen_string_literal: true

# Controller for managing reports
# rubocop:disable Metrics/ClassLength
class ReportsController < ApplicationController
  sidebar_item :reports

  def index # rubocop:disable Metrics/MethodLength
    authorize(:report, :index?)

    @scorecards = policy_scope(Scorecard).order(:name)
    @grouped_scorecards = @scorecards.group_by(&:type).transform_keys do |key|
      case key
      when 'TransitionCard' then current_account.transition_card_model_name
      when 'SustainableDevelopmentGoalAlignmentCard' then current_account.sdgs_alignment_card_model_name
      else
        'Impact Card'
      end
    end.transform_values do |scorecards| # rubocop:disable Style/MultilineBlockChain
      scorecards.map do |scorecard|
        [scorecard.name, scorecard.id]
      end
    end
  end

  def initiatives # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    authorize(:report, :index?) # SMELL Incorrect policy check. Need to fix.

    @content_subtitle = 'Initiatives'

    query = policy_scope(Initiative).joins(scorecard: %i[community wicked_problem])

    wicked_problem_ids = params[:wicked_problems].reject { |e| e.to_s.empty? }
    community_ids = params[:communities].reject { |e| e.to_s.empty? }

    query = query.where('scorecards.wicked_problem_id': wicked_problem_ids) if wicked_problem_ids

    query = query.where('scorecards.community_id': community_ids) if community_ids

    @results = query.select(
      :id,
      :name,
      :description,
      :created_at,
      :scorecard_id,
      'wicked_problems.name as wicked_problem_name',
      'communities.name as community_name',
      'scorecards.name as scorecard_name'
    ).distinct.page(params[:page])
  end

  def stakeholders # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    authorize(:report, :index?)

    @content_subtitle = 'Stakeholders'

    query = current_account.organisations.joins(
      :stakeholder_type,
      initiatives: [scorecard: %i[wicked_problem community]]
    )

    query = query.where(stakeholder_type_id: params[:stakeholder_type]) if params[:stakeholder_type].present?

    query = query.where('scorecards.wicked_problem_id': params[:wicked_problem]) if params[:wicked_problem].present?

    query = query.where('scorecards.community_id': params[:community]) if params[:community].present?

    @results = query.select(
      :id,
      :name,
      :description,
      :created_at,
      :stakeholder_type_id,
      'stakeholder_types.name as stakeholder_type_name',
      'wicked_problems.name as wicked_problem_name',
      'communities.name as community_name',
      'scorecards.name as scorecard_name'
    ).distinct.page(params[:page])
  end

  def transition_card_activity # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    authorize(:report, :transition_card_activity?)

    @content_subtitle = "#{Scorecard.model_name.human} Activity"

    @date_from = ActiveSupport::TimeZone[current_user.time_zone].parse(params[:date_from]).beginning_of_day.utc

    @date_to = ActiveSupport::TimeZone[current_user.time_zone].parse(params[:date_to]).end_of_day.utc

    @date_to = Date.parse(params[:date_to]).end_of_day
    @scorecard = current_account.scorecards.find(params[:scorecard_id])

    @report = Reports::TransitionCardActivity.new(@scorecard, @date_from, @date_to)

    respond_to do |format|
      format.html
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

    @content_subtitle = "#{Scorecard.model_name.human} Comments"

    @scorecard = current_account
                 .scorecards
                 .includes(initiatives: [checklist_items: [characteristic: [focus_area: :focus_area_group]]])
                 .find(params[:scorecard_id])

    @date = ActiveSupport::TimeZone[current_user.time_zone].parse(params[:date]).end_of_day.utc

    @status = params[:status]

    @report = Reports::ScorecardComments.new(@scorecard, @date, @status, current_user.time_zone)

    respond_to do |format|
      format.html
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

  def transition_card_stakeholders
    authorize(:report, :index?)

    # SMELL: Is @content_subtitle used?
    @content_subtitle = "#{current_account.transition_card_model_name} Stakeholder Report"
    @scorecard = current_account.scorecards.find(params[:scorecard_id])
    @report = Reports::TransitionCardStakeholders.new(@scorecard)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "#{transition_card_stakeholders_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
    )
  end

  def subsystem_summary
    authorize(:report, :subsystem_summary?)

    @scorecard = current_account.scorecards.find(params[:scorecard_id])
    @report = Reports::SubsystemSummary.new(@scorecard)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "#{subsystem_summary_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
    )
  end

  def cross_account_percent_actual
    authorize(:report, :cross_account_percent_actual?)

    @accounts = current_user.active_accounts_with_admin_role
    @report = Reports::CrossAccountPercentActual.new(@accounts)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "Cross_Account_Percent_Actual_#{time_stamp_suffix}.xlsx"
    )
  end

  def cross_account_percent_actual_by_focus_area
    authorize(:report, :cross_account_percent_actual_by_focus_area?)

    @accounts = current_user.active_accounts_with_admin_role
    @report = Reports::CrossAccountPercentActualByFocusArea.new(@accounts)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "Cross_Account_Percent_Actual_By_Focus_Area_#{time_stamp_suffix}.xlsx"
    )
  end

  def cross_account_percent_actual_by_focus_area_tabbed
    authorize(:report, :cross_account_percent_actual_by_focus_area_tabbed?)

    @accounts = current_user.active_accounts_with_admin_role
    @report = Reports::CrossAccountPercentActualByFocusAreaTabbed.new(@accounts)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "Cross_Account_Percent_Actual_By_Focus_Area_Tabbed_#{time_stamp_suffix}.xlsx"
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

  def transition_card_stakeholders_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_Stakeholders"
  end

  def subsystem_summary_base_filename(scorecard)
    "#{report_filename_prefix(scorecard)}_Subsystems"
  end

  def report_filename_prefix(scorecard)
    scorecard.model_name.human.delete(' ')
  end

  def time_stamp_suffix
    Time.zone.now.strftime('_%Y_%m_%d')
  end
end
# rubocop:enable Metrics/ClassLength
