# frozen_string_literal: true

class RemoveInitiativesSubsystemTagsForDeletedSubsystemTags < ActiveRecord::Migration[8.0]
  def up
    subsystem_tags_to_remove.each do |tag|
      tag.initiatives_subsystem_tags.delete_all
    end
  end

  def down
    # NO OP
  end

  private

  def subsystem_tags_to_remove
    SubsystemTag.with_deleted.where.not(deleted_at: nil).select { |tag| tag.initiatives_subsystem_tags.present? }
  end
end
