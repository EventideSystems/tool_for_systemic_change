# frozen_string_literal: true

module ScorecardsHelper
  ACTUAL_OR_PLANNED = %w[actual planned].freeze

  def activity_occurred_at(activity)
    activity.occurred_at.in_time_zone(current_user.time_zone).strftime('%F %T %Z')
  end

  def display_scorecard_model_name(scorecard)
    return '' if scorecard&.account.blank?

    case scorecard
    when TransitionCard
      scorecard.account.transition_card_model_name
    when SustainableDevelopmentGoalAlignmentCard
      scorecard.account&.sdgs_alignment_card_model_name
    end
  end

  def lookup_communities
    controller.current_account.communities.order(:name)
  end

  def lookup_organisations
    controller.current_account.organisations.order(:name)
  end

  def lookup_subsystem_tags
    controller.current_account.subsystem_tags.order(:name)
  end

  def lookup_wicked_problems
    controller.current_account.wicked_problems.order(:name)
  end

  def cell_class(result, _focus_areas, characteristic)
    return 'cell hidden' if result.blank?

    characteristic_data = result[characteristic.id.to_s]

    return 'cell hidden' if characteristic_data.blank?

    [
      'cell',
      "#{characteristic_data[:status].dasherize}#{@focus_areas.index(characteristic.focus_area) + 1}",
      characteristic_data[:status].dasherize
    ].tap do |class_names|
      class_names << 'hidden' unless characteristic_data[:status] == 'actual'
    end.join(' ')
  end

  # def cell_style(result, _focus_areas, characteristic)
  #   return '' if result.blank?

  #   characteristic_data = result[characteristic.id.to_s]

  #   return '' if characteristic_data.blank?

  #   case characteristic_data[:status]
  #   when 'actual' then "background-color: #{characteristic.focus_area.actual_color}"
  #   when 'planned'
  #     "background-color: #{characteristic.focus_area.planned_color}"
  #   when 'no_comment'
  #     "background: repeating-linear-gradient(
  #     45deg,
  #     transparent,
  #     transparent 1px,
  #     #{characteristic.focus_area.actual_color} 2px,
  #     #{characteristic.focus_area.actual_color} 3px
  #     );"
  #   else
  #     ''
  #   end
  # end

  def collection_for_linked_scorecard(parent_scorecard)
    return [] if parent_scorecard.blank?

    [['', nil]] + parent_scorecard
                  .account
                  .scorecards
                  .where(id: parent_scorecard.linked_scorecard_id)
                  .or(parent_scorecard.account.scorecards.where(linked_scorecard_id: nil))
                  .where.not(type: parent_scorecard.type, deleted_at: nil)
                  .order(:name)
                  .pluck(:name, :id)
  end

  def focus_area_cell_style(result, focus_area)
    characteristic_ids = focus_area.characteristics.pluck(:id).map(&:to_s)

    any_actual = result.values_at(*characteristic_ids).any? { |checklist_item| checklist_item[:status] == 'actual' }

    any_actual ? "background-color: #{focus_area.actual_color}" : ''
  end

  def linked_scorecard_label(scorecard)
    'Linked ' +
      case scorecard
      when TransitionCard then SustainableDevelopmentGoalAlignmentCard
      when SustainableDevelopmentGoalAlignmentCard then TransitionCard
      else
        raise('Unknown scorecard type')
      end.model_name.human
  end

  def scorecard_path(scorecard)
    case scorecard.type
    when 'TransitionCard' then transition_card_path(scorecard)
    when 'SustainableDevelopmentGoalAlignmentCard' then sustainable_development_goal_alignment_card_path(scorecard)
    end
  end

  def copy_scorecard_url(scorecard)
    case scorecard.type
    when 'TransitionCard' then copy_transition_card_url(@scorecard)
    when 'SustainableDevelopmentGoalAlignmentCard' then copy_sustainable_development_goal_alignment_card_url(scorecard)
    end
  end
end
