# frozen_string_literal: true

module VersionsHelper
  def version_summary(version)
    return '' if version.blank?

    item_name = version_item_name(version)
    item_type_name = version_item_type_name(version.item_type)

    "#{item_type_name} '#{item_name}'"
  end

  def version_whodunnit(version)
    return '' if version.blank?

    version_whodunnit_name(version.whodunnit)
  end

  def version_event_past_tense(version_event)
    version_event == 'destroy' ? 'destroyed' : "#{version_event}d"
  end

  def version_whodunnit_name(version_whodunnit)
    User.where(id: version_whodunnit).first&.name || '[UNKNOWN]'
  end

  def version_item_name(version)
    return '[DELETED]' if version.item.nil?
    return version.item.name if version.item.respond_to?(:name)

    '[UNKNOWN]'
  rescue NameError => e
    "[UNEXPECTED] #{e.missing_name}"
  end

  def version_item_type_name(version_item_type)
    return Scorecard.model_name.human if version_item_type == 'Scorecard'

    version_item_type&.underscore&.titleize
  end
end
