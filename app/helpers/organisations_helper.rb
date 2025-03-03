# frozen_string_literal: true

# Helper methods for presenting organisations (aka stakeholders)
module OrganisationsHelper
  def options_for_organisation_select(selected = nil)
    organisations = policy_scope(Organisation).order('lower(name)')
    options_from_collection_for_select(organisations, :id, :name, selected&.id)
  end
end
