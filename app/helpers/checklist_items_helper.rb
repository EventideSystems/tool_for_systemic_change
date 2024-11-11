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

  # TODO: Move these into the models
  CHECKLIST_LIST_ITEM_COLOR_CLASSES = {
    actual: 'bg-sky-600',
    planned: 'bg-teal-500',
    more_information: 'bg-yellow-400',
    suggestion: 'bg-indigo-400',
    other: 'bg-gray-200 dark:bg-gray-600'
  }.freeze

  CHECKLIST_LIST_ITEM_RADIO_BUTTON_COLOR_CLASSES = {
    actual: 'text-sky-600 focus:ring-sky-600',
    planned: 'text-teal-500 focus:ring-teal-500',
    more_information: 'text-yellow-400 focus:ring-yellow-400',
    suggestion: 'text-indigo-400 focus:ring-indigo-400'
  }.freeze

  # Original colors
  # $color-actual: #009BCC;
  # $color-planned: #00CCAA;
  # $color-suggestion: #F7C80B;
  # $color-more-information: #7993F2;

  def focus_area_grid_element(focus_area_data)
    content_tag(
      :div,
      '',
      class: 'w-1 h-3',
      style: "background-color: #{focus_area_data[:focus_area_color]}",
      title: focus_area_data[:focus_area_name]
    )
  end

  def checklist_list_item_grid_element(checklist_item_data)
    background_color = checklist_list_item_grid_element_color(checklist_item_data[:status])

    content_tag(
      :div,
      '',
      class: "p-1.5 h-2 rounded-sm #{background_color}",
      title: checklist_item_data[:name],
      data: { status: checklist_item_data[:status] }
    )
  end

  def current_comment_status_style(checklist_item)
    return 'no-comment' if checklist_item.comment.blank?

    checklist_item.status.to_s.dasherize
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
