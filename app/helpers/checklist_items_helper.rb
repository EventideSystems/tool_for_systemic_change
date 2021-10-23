module ChecklistItemsHelper

  def current_comment_status_style(checklist_item)
    return '' if checklist_item.current_comment.blank?
    checklist_item.current_checklist_item_comment.status.to_s
  end

  def comment_statuses_collection
    ChecklistItemComment.statuses.keys.map do |key| 
      [I18n.t("activerecord.attributes.checklist_item_comment/status.#{key}"), key]
    end
  end
end
