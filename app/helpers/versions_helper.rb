module VersionsHelper
  def version_summary(version)
    return '' unless version.present?

    item_name = version_item_name(version)
    item_type_name = version_item_type_name(version.item_type)
    whodunnit_name = version_whodunnit_name(version.whodunnit)
    event_past_tense = version_event_past_tense(version.event)

    "#{item_type_name} '#{item_name}' #{event_past_tense} by #{whodunnit_name}"
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
