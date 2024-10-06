# frozen_string_literal: true

module ChecklistItemsHelper

  # rubocop:disable Layout/HashAlignment
  BASE_CONCURRENT_CHECKLIST_LIST_ITEM_COLOR_CLASSES = {
    red:     'bg-red-600',
    orange:  'bg-orange-600',
    amber:   'bg-amber-600',
    yellow:  'bg-yellow-600',
    lime:    'bg-lime-600',
    green:   'bg-green-600',
    emerald: 'bg-emerald-600',
    teal:    'bg-teal-600',
    cyan:    'bg-cyan-600',
    sky:     'bg-sky-600',
    blue:    'bg-blue-600',
    indigo:  'bg-indigo-600',
    violet:  'bg-violet-600',
    purple:  'bg-purple-600',
    fuchsia: 'bg-fuchsia-600',
    pink:    'bg-pink-600',
    rose:    'bg-rose-600'
  }.freeze
  # rubocop:enable Layout/HashAlignment

  CHECKLIST_LIST_ITEM_COLOR_CLASSES = {
    actual: 'bg-blue-600',
    planned: 'bg-green-600',
    more_information: 'bg-yellow-600',
    suggestion: 'bg-fuchsia-600',
    other: 'bg-gray-300'
  }.freeze

  def checklist_list_item_grid_element(checklist_item_data)
    background_color = checklist_list_item_grid_element_color(checklist_item_data[:status])

    content_tag(
      :div,
      '',
      class: "p-2 h-2 rounded-sm #{background_color}",
      title: checklist_item_data[:name],
      data: { status: checklist_item_data[:status] }
    )
  end

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

  private

  def checklist_list_item_grid_element_color(status)
    CHECKLIST_LIST_ITEM_COLOR_CLASSES[status.to_sym].presence ||
      CHECKLIST_LIST_ITEM_COLOR_CLASSES[:other]
  end
end
