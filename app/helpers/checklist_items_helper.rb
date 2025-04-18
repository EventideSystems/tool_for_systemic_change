# frozen_string_literal: true

# Helper methods for presenting checklist items
module ChecklistItemsHelper
  #
  # BASE_CONCURRENT_CHECKLIST_LIST_ITEM_COLOR_CLASSES = {
  #   red:     'bg-red-600',
  #   orange:  'bg-orange-600',
  #   amber:   'bg-amber-600',
  #   yellow:  'bg-yellow-600',
  #   lime:    'bg-lime-600',
  #   green:   'bg-green-600',
  #   emerald: 'bg-emerald-600',
  #   teal:    'bg-teal-600',
  #   cyan:    'bg-cyan-600',
  #   sky:     'bg-sky-600',
  #   blue:    'bg-blue-600',
  #   indigo:  'bg-indigo-600',
  #   violet:  'bg-violet-600',
  #   purple:  'bg-purple-600',
  #   fuchsia: 'bg-fuchsia-600',
  #   pink:    'bg-pink-600',
  #   rose:    'bg-rose-600'
  # }.freeze
  #   # TODO: Move these into the models
  CHECKLIST_LIST_ITEM_COLOR_CLASSES = {
    actual: 'bg-sky-600',
    planned: 'bg-teal-500',
    more_information: 'bg-yellow-400',
    suggestion: 'bg-indigo-400',
    other: 'bg-gray-300 dark:bg-gray-600'
  }.freeze

  CHECKLIST_LIST_ITEM_COLOR_OPACITY = {
    actual: 'FF',
    planned: '99',
    more_information: '66',
    suggestion: '40',
    other: '00'
  }.freeze

  # SMELL: Move to CSS config
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
      class: 'w-2 h-3',
      style: "background-color: #{focus_area_data[:focus_area_color]}",
      title: focus_area_data[:focus_area_name]
    )
  end

  def checklist_list_item_grid_element(checklist_item_data:, grid_mode:)
    element_class = checklist_list_item_grid_element_class(checklist_item_data:, grid_mode:)
    options = checklist_list_item_grid_element_base_options(checklist_item_data, element_class)

    content_tag(:div, '', options)
  end

  def checklist_list_item_status_color(status)
    CHECKLIST_LIST_ITEM_COLOR_CLASSES[status.to_sym].presence ||
      CHECKLIST_LIST_ITEM_COLOR_CLASSES[:other]
  end

  def checklist_list_item_grid_element_class(checklist_item_data:, grid_mode:)
    status = checklist_item_data[:status].dasherize

    return 'status-no-comment' if status == 'no-comment'
    return "status-#{status}" unless grid_mode == :classic

    "status-focus-area-#{checklist_item_data[:focus_area_id]}-#{status}"
  end

  private

  def checklist_list_item_grid_element_base_options(checklist_item_data, element_class)
    {
      class: 'p-1.5 h-2 rounded-sm',
      title: checklist_item_data[:name],
      data: {
        status: checklist_item_data[:status],
        element_class:
        # focus_area_color: checklist_item_data[:focus_area_color]
      }
    }
  end
end
