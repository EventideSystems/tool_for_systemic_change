# frozen_string_literal: true

module ReportsHelper
  def options_for_comment_statuses
    ChecklistItemComment.statuses.keys.map { |status| [status.titleize, status] }
  end
end
