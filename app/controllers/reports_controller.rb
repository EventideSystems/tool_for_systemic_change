# frozen_string_literal: true

class ReportsController < ApplicationController
  skip_after_action :verify_policy_scoped
  # skip_after_action :verify_authorized

  add_breadcrumb 'Reports', :reports_path

  ScorecardType = Struct.new('ScorecardType', :name, :scorecards)

  def index
    authorize(:report, :index?)

    @scorecards = policy_scope(Scorecard).order(:name)

    @scorecard_types =
      current_account.scorecard_types.map do |scorecard_type|
        ScorecardType.new(
          scorecard_type.model_name.human.pluralize,
          policy_scope(Scorecard).order(:name).where(type: scorecard_type.name)
        )
      end
  end

  def initiatives
    authorize(:report, :index?) # SMELL Incorrect policy check. Need to fix.

    @content_subtitle = 'Initiatives'
    add_breadcrumb(@content_subtitle)

    query = policy_scope(Initiative).joins(scorecard: %i[community wicked_problem])

    wicked_problem_ids = params[:report][:wicked_problems].reject { |e| e.to_s.empty? }
    community_ids = params[:report][:communities].reject { |e| e.to_s.empty? }

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

  def stakeholders
    authorize(:report, :index?)

    @content_subtitle = 'Stakeholders'
    add_breadcrumb(@content_subtitle)

    query = current_account.organisations.joins(:stakeholder_type, initiatives: [scorecard: %i[wicked_problem community]])

    query = query.where(stakeholder_type_id: params[:report][:stakeholder_type]) unless params[:report][:stakeholder_type].blank?

    unless params[:report][:wicked_problem].blank?
      query = query.where('scorecards.wicked_problem_id': params[:report][:wicked_problem])
    end

    unless params[:report][:community].blank?
      query = query.where('scorecards.community_id': params[:report][:community])
    end

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

  def transition_card_activity
    authorize(:report, :transition_card_activity?)

    @content_subtitle = "#{Scorecard.model_name.human} Activity"
    add_breadcrumb(@content_subtitle)

    @date_from = Date.parse(params[:report][:date_from]).beginning_of_day
    @date_to = Date.parse(params[:report][:date_to]).end_of_day
    @scorecard = current_account.scorecards.find(params[:report][:scorecard_id])

    @report = Reports::TransitionCardActivity.new(@scorecard, @date_from, @date_to)

    respond_to do |format|
      format.html
      format.xlsx do
        send_data(
          @report.to_xlsx.read,
          type: Mime[:xlsx],
          filename: "#{scorecard_activity_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
        )
      end
    end
  end

  def transition_card_activity
    authorize(:report, :transition_card_activity?)

    @content_subtitle = "#{Scorecard.model_name.human} Activity"
    add_breadcrumb(@content_subtitle)

    @date_from = \
      ActiveSupport::TimeZone[current_user.time_zone]
        .parse(params[:report][:date_from])
        .beginning_of_day
        .utc

    @date_to = \
      ActiveSupport::TimeZone[current_user.time_zone]
        .parse(params[:report][:date_to])
        .end_of_day
        .utc

    @date_to = Date.parse(params[:report][:date_to]).end_of_day
    @scorecard = current_account.scorecards.find(params[:report][:scorecard_id])

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

  def scorecard_comments
    authorize(:report, :index?)

    @content_subtitle = "#{Scorecard.model_name.human} Comments"
    add_breadcrumb(@content_subtitle)

    @scorecard = current_account
                 .scorecards
                 .includes(initiatives: [checklist_items: [characteristic: [focus_area: :focus_area_group]]])
                 .find(params[:report][:scorecard_id])

    @date = \
      ActiveSupport::TimeZone[current_user.time_zone]
        .parse(params[:report][:date])
        .end_of_day
        .utc

    @status = params[:report][:status]

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

    @content_subtitle = 'Transition Card Stakeholder Report'
    add_breadcrumb(@content_subtitle)

    @scorecard = current_account.scorecards.find(params[:report][:scorecard_id])
    @report = Reports::TransitionCardStakeholders.new(@scorecard)
    send_data(
      @report.to_xlsx.read,
      type: Mime[:xlsx],
      filename: "#{transition_card_stakeholders_base_filename(@scorecard)}#{time_stamp_suffix}.xlsx"
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

  def report_filename_prefix(scorecard)
    scorecard.model_name.human.delete(' ')
  end

  def time_stamp_suffix
    Time.zone.now.strftime('_%Y_%m_%d')
  end
end
