class SearchResultsController < ApplicationController

  # add_breadcrumb "Search Results"

  def index
    # add_breadcrumb "'#{params[:query]}'"

    query = params[:query].present? ? "%#{params[:query]}%" : ''

    @search_results = []

    policy_scope(WickedProblem)
      .where('name ILIKE ? OR description ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.description, wicked_problem_path(value))
      end

    policy_scope(Scorecard)
      .where('name ILIKE ? OR description ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.description, transition_card_path(value))
      end

    policy_scope(Initiative)
      .where('initiatives.name ILIKE ? OR initiatives.description ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.description, initiative_path(value))
      end

    policy_scope(Community)
      .where('name ILIKE ? OR description ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.description, community_path(value))
      end

    policy_scope(Organisation)
      .where('name ILIKE ? OR description ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.description, organisation_path(value))
      end

    policy_scope(Account)
      .where('name ILIKE ? OR description ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.description, account_path(value))
      end

    policy_scope(User)
      .where('name ILIKE ? OR email ILIKE ?', query, query)
      .each_with_object(@search_results) do |value, memo|
        memo << SearchResult.new(value.model_name.human, value.name, value.email, user_path(value))
      end
  end

end
