# frozen_string_literal: true

class AddIndexToInitiativesOrganisationsInitiativeId < ActiveRecord::Migration[7.0]
  def change
    add_index(:initiatives_organisations, :initiative_id)
  end
end
