# frozen_string_literal: true

require 'csv'

module ImpactCards
  # Controller for Stakeholder network for each ImpactCard
  class StakeholderNetworkController < ApplicationController
    include ActiveTabItem

    sidebar_item :impact_cards
    tab_item :network

    def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @scorecard = Scorecard.find(params[:impact_card_id])
      authorize(@scorecard, :show?)

      @graph = @scorecard.stakeholder_network

      @stakeholder_types = @scorecard.stakeholder_types.order('lower(trim(name))')
      @legend_items = @stakeholder_types.map do |stakeholder_type|
        { label: stakeholder_type.name, color: stakeholder_type.color }
      end

      @show_labels = params[:show_labels].in?(%w[true 1])

      @selected_stakeholder_types =
        if params[:stakeholder_types].blank?
          StakeholderType.none
        else
          StakeholderType.where(workspace: current_workspace, name: params[:stakeholder_types].compact)
        end

      respond_to do |format|
        format.html
        format.csv do
          send_data stakeholder_network_csv(@graph, @scorecard),
                    filename: "stakeholder-network-#{@scorecard.id}-#{Time.zone.now.strftime('%Y%m%d')}.csv",
                    type: 'text/csv'
        end
      end
    end

    private

    def stakeholder_network_csv(graph, _scorecard) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      CSV.generate(headers: true) do |out|
        out << %w[stakeholder partnering_initiatives partnering_stakeholders connections betweenness]

        id_to_label = graph.nodes.to_h { |n| [n[:id], n[:label]] }

        neighbors = Hash.new { |h, k| h[k] = [] }
        graph.links.each do |link|
          source = link[:source]
          target = link[:target]
          neighbors[source] << id_to_label[target] if id_to_label[target]
          neighbors[target] << id_to_label[source] if id_to_label[source]
        end

        graph.nodes.each do |node|
          label = node[:label]
          linked_labels = neighbors[node[:id]].uniq.sort.join('; ')
          initiatives = Array(node[:partnering_initiatives]).map(&:to_s).uniq.sort.join('; ')
          betweenness = node[:betweenness]
          connections = neighbors[node[:id]].size

          out << [label, initiatives, linked_labels, connections, betweenness]
        end
      end
    end
  end
end
