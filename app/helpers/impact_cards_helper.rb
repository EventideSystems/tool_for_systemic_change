# frozen_string_literal: true

# Helper methods for managing and displaying impact cards and related data
module ImpactCardsHelper
  ACTUAL_OR_PLANNED = %w[actual planned].freeze

  def activity_occurred_at(activity)
    activity.occurred_at.in_time_zone(current_user.time_zone).strftime('%F %T %Z')
  end

  def display_scorecard_model_name(scorecard)
    return '' if scorecard&.workspace.blank?

    case scorecard
    when TransitionCard
      scorecard.workspace.transition_card_model_name
    when SustainableDevelopmentGoalAlignmentCard
      scorecard.workspace&.sdgs_alignment_card_model_name
    end
  end

  def multi_select_options_for_labels(labels, selected_labels)
    choices = labels.map do |label|
      color_class = dom_id(label)
      icon = { icon: "<div class=\"w-3 h-3 mt-1 mr-2 bg-gray-500 rounded-full #{color_class}\">&nbsp;</div>".html_safe } # rubocop:disable Rails/OutputSafety
      [label.name, { data: { hs_select_option: icon.to_json(escape_html_entities: false) } }]
    end

    selected = selected_labels.map(&:name)

    options_for_select(choices, selected)
  end

  # NOTE: Statuses are expected to be an array of string pairs, e.g. [["Actual", "actual"], ["Planned", "planned"] ...]
  #       Selected statuses are expected to be an array of strings, e.g. ["actual", "planned", ...]
  #
  #       The color class is determined by the status name, itself expected to be a symbol, e.g. :actual, :planned, ...
  def multi_select_options_for_statuses(statuses, selected_statuses, impact_card)
    choices = choices_for_statuses(statuses, impact_card).map do |choice|
      status = choice[0]
      icon = choice[1]
      [*status, { data: { hs_select_option: icon.to_json(escape_html_entities: false) } }]
    end

    options_for_select(choices, selected_statuses)
  end

  def choices_for_statuses(statuses, impact_card) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    focus_area_groups = impact_card.workspace.focus_area_groups.where(scorecard_type: impact_card.type)
    focus_areas = FocusArea.where(focus_area_group: focus_area_groups).order(:scorecard_type, :position)
    classic_mode_colors = focus_areas.map(&:actual_color).values_at(0, focus_areas.length / 2, -1).uniq

    statuses.map do |status|
      if impact_card.grid_mode.to_sym == :classic
        icons = classic_mode_colors.map do |color|
          opacity = ChecklistItemsHelper::CHECKLIST_LIST_ITEM_COLOR_OPACITY[status[1].to_sym]
          status_color = "#{color}#{opacity}"

          "<div class=\"w-3 h-3 mt-1 bg-gray-500 rounded-full\" style=\"background-color: #{status_color}\">&nbsp;</div>".html_safe # rubocop:disable Rails/OutputSafety,Layout/LineLength
        end
        icon = { icon: "<div class='flex mr-2'>#{icons.join('')}<div>".html_safe } # rubocop:disable Rails/OutputSafety
      else
        color_class = ChecklistItemsHelper::CHECKLIST_LIST_ITEM_COLOR_CLASSES[status[1].to_sym]
        icon = { icon: "<div class=\"w-3 h-3 mt-1 mr-2 bg-gray-500 rounded-full #{color_class}\">&nbsp;</div>".html_safe } # rubocop:disable Rails/OutputSafety,Layout/LineLength
      end

      [status, icon]
    end
  end

  def cell_class(result, focus_areas, characteristic)
    return 'cell hidden' if result.blank?

    characteristic_data = result[characteristic.id.to_s]

    return 'cell hidden' if characteristic_data.blank?

    [
      'cell',
      "#{characteristic_data[:status].dasherize}#{focus_areas.index(characteristic.focus_area) + 1}",
      characteristic_data[:status].dasherize
    ].tap do |class_names|
      class_names << 'hidden' unless characteristic_data[:status] == 'actual'
    end.join(' ')
  end

  # def collection_for_linked_scorecard(parent_scorecard)
  #   return [] if parent_scorecard.blank?

  #   [['', nil]] + parent_scorecard
  #                 .workspace
  #                 .scorecards
  #                 .where(id: parent_scorecard.linked_scorecard_id)
  #                 .or(parent_scorecard.workspace.scorecards.where(linked_scorecard_id: nil))
  #                 .where.not(type: parent_scorecard.type, deleted_at: nil)
  #                 .order(:name)
  #                 .pluck(:name, :id)
  # end

  def focus_area_cell_style(result, focus_area)
    characteristic_ids = focus_area.characteristics.pluck(:id).map(&:to_s)

    any_actual = result.values_at(*characteristic_ids).any? { |checklist_item| checklist_item[:status] == 'actual' }

    any_actual ? "background-color: #{focus_area.actual_color}" : ''
  end

  # def linked_scorecard_label(scorecard)
  #   'Linked ' +
  #     case scorecard
  #     when TransitionCard then SustainableDevelopmentGoalAlignmentCard
  #     when SustainableDevelopmentGoalAlignmentCard then TransitionCard
  #     else
  #       raise('Unknown scorecard type')
  #     end.model_name.human
  # end

  def select_impact_card_tag(name, options)
    workspace = options.delete(:workspace) || current_workspace

    collection_options = if workspace.scorecard_types_in_use.count > 1
                           grouped_scorecards = grouped_impact_cards_for_workspace(workspace)
                           grouped_options_for_select(grouped_scorecards)
                         else
                           scorecards = workspace.scorecards.order(:name)
                           options_from_collection_for_select(scorecards, :id, :name)
                         end

    custom_select_tag(name, collection_options, options)
  end

  private

  def grouped_impact_cards_for_workspace(workspace) # rubocop:disable Metrics/MethodLength
    workspace.scorecards.group_by(&:type).transform_keys do |key|
      case key
      when 'TransitionCard' then workspace.transition_card_model_name
      when 'SustainableDevelopmentGoalAlignmentCard' then workspace.sdgs_alignment_card_model_name
      else
        'Impact Card'
      end
    end.transform_values do |scorecards| # rubocop:disable Style/MultilineBlockChain
      scorecards.map do |scorecard|
        [scorecard.name, scorecard.id]
      end
    end
  end
end
