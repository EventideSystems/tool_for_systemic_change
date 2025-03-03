# frozen_string_literal: true

# Helper methods for presenting subsytem tags
module SubsystemTagsHelper
  def options_for_subsystem_tag_select(selected = nil)
    subsystem_tags = policy_scope(SubsystemTag).order('lower(name)')
    options_from_collection_for_select(subsystem_tags, :id, :name, selected&.id)
  end
end
