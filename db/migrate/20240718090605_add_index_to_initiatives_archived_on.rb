# frozen_string_literal: true

class AddIndexToInitiativesArchivedOn < ActiveRecord::Migration[7.0]
  def change
    add_index(:initiatives, :archived_on)
  end
end
