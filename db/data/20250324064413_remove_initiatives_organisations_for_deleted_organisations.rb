# frozen_string_literal: true

class RemoveInitiativesOrganisationsForDeletedOrganisations < ActiveRecord::Migration[8.0]
  def up
    organisations_to_remove.each do |organisation|
      organisation.initiatives_organisations.delete_all
    end
  end

  def down
    # NO OP
  end

  def organisations_to_remove
    Organisation.with_deleted.where.not(deleted_at: nil).select { |tag| tag.initiatives_organisations.present? }
  end
end
