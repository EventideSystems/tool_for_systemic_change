# frozen_string_literal: true

module ChecklistItemsHelper
  def current_comment_status_style(checklist_item)
    return 'no-comment' if checklist_item.comment.blank?

    checklist_item.status.to_s.dasherize
  end

  def comment_statuses_collection
    @comment_statuses_collection ||=
      ChecklistItemComment.statuses.keys.map do |key|
        [I18n.t("activerecord.attributes.checklist_item_comment/status.#{key}"), key]
      end
  end

  def checklist_item_badge(checklist_item)
    klass = checklist_item.no_comment? ? 'fa-square-o' : 'fa-square'

    content_tag(
      :i,
      '',
      class: "badge-checklist-item fa #{klass} #{checklist_item.status.dasherize}",
      data: {
        comments_target: 'badge',
        toggle: 'tooltip',
        placement: 'top',
        title: checklist_item.status.humanize
      }
    )
  end
end
