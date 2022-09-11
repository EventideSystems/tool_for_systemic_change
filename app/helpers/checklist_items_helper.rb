# frozen_string_literal: true

module ChecklistItemsHelper
  def current_comment_status_style(checklist_item)
    return '' if checklist_item.comment.blank?

    checklist_item.status.to_s
  end

  def comment_statuses_collection
    @comment_statuses_collection ||= ChecklistItemComment.statuses.keys.map do |key|
      [I18n.t("activerecord.attributes.checklist_item_comment/status.#{key}"), key]
    end
  end

  def checklist_item_badge(checklist_item)
    content_tag(
      :span,
      '&nbsp;&nbsp;'.html_safe,
      class: "badge badge-checklist-item #{checklist_item.status.gsub('_', '-')}",
      data: {
        comments_target: "badge",
        toggle: "tooltip",
        placement: "top",
        title: checklist_item.status.humanize
      }
    )
  end
end
