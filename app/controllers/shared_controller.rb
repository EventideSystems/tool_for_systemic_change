# frozen_string_literal: true

# Controller for managing shared impact cards
class SharedController < ApplicationController
  include ActiveTabItem

  skip_before_action :set_session_account_id
  skip_before_action :authenticate_user!
  skip_before_action :set_paper_trail_whodunnit

  before_action :set_scorecard

  def show # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
    tab_item :grid
    response.headers.delete('X-Frame-Options')

    @date = params[:date]
    @parsed_date = @date.blank? ? nil : Date.parse(@date)

    @subsystem_tags = @scorecard.subsystem_tags.order('lower(trim(subsystem_tags.name))').uniq
    @statuses = ChecklistItem.statuses.keys.excluding('no_comment').map { |status| [status.humanize, status] }

    @selected_statuses = params[:statuses]

    @selected_subsystem_tags =
      if params[:subsystem_tags].blank?
        SubsystemTag.none
      else
        SubsystemTag.where(account: @scorecard.account, name: params[:subsystem_tags].compact)
      end

    @scorecard_grid = ScorecardGrid.execute(@scorecard, @parsed_date)

    if @scorecard.present?
      if params[:iframe] == 'true'
        render('show_iframe', layout: false)
      else
        render(layout: 'embedded')
      end

    else
      render(file: 'public/404.html', layout: 'embedded', status: :not_found)
    end
  end

  def stakeholder_network # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    tab_item :network

    @graph = Insights::StakeholderNetwork.new(@scorecard)

    @stakeholder_types = @scorecard.stakeholder_types.order('lower(trim(name))')

    @show_labels = params[:show_labels].in?(%w[true 1])

    @selected_stakeholder_types =
      if params[:stakeholder_types].blank?
        StakeholderType.none
      else
        StakeholderType.where(account: @scorecard.account, name: params[:stakeholder_types].compact)
      end

    render(layout: 'embedded')
  end

  def thematic_map # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    tab_item :thematic_map

    @graph = Insights::TargetsNetwork.new(@scorecard)
    @stakeholder_types = @scorecard.stakeholder_types.order(:name).uniq

    @show_labels = params[:show_labels].in?(%w[true 1])

    @stakeholders = @scorecard.organisations.order(Arel.sql('trim(organisations.name)')).uniq
    @selected_stakeholders =
      if params[:stakeholders].blank?
        Organisation.none
      else
        Organisation.where(account: @scorecard.account, name: params[:stakeholders].compact)
      end

    @initiatives = @scorecard.initiatives.order(:name).uniq
    @selected_initiatives =
      if params[:initiatives].blank?
        Initiative.none
      else
        @scorecard.initiatives.where(name: params[:initiatives].compact)
      end

    render(layout: 'embedded')
  end

  private

  def set_scorecard
    @scorecard = Scorecard.find_by(shared_link_id: params[:id])
  end
end
