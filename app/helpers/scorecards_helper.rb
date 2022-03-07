# frozen_string_literal: true

module ScorecardsHelper
  ACTUAL_OR_PLANNED = %w[actual planned].freeze

  def activity_occurred_at(activity)
    activity.occurred_at.in_time_zone(current_user.time_zone).strftime('%F %T %Z')
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

  def display_selected_date
    return 'Select Date' if @selected_date.blank?

    Date.parse(@selected_date).strftime('%B %-d, %Y')
  end

  def cell_class(result, _focus_areas, characteristic)
    classes = ['cell']

    return 'cell hidden' if result.blank?

    characteristic_data = result[characteristic.id.to_s]

    return 'cell hidden' if characteristic_data.blank?

    if characteristic_data['status'].in?(ACTUAL_OR_PLANNED) && characteristic_data['comment'].present?
      classes << [
        "#{characteristic_data['status']}#{@focus_areas.index(characteristic.focus_area) + 1}",
        characteristic_data['status']
      ]

      classes << 'hidden' unless characteristic_data['status'] == 'actual'
    else
      if characteristic_data['checked']
        classes << [
          "checked#{@focus_areas.index(characteristic.focus_area) + 1}",
          'checked'
        ]
      end

      classes << if characteristic_data['status'] == 'checked' && characteristic_data['comment'].blank?
                   ['no-comment', "no-comment#{@focus_areas.index(characteristic.focus_area) + 1}"]
                 else
                   'gap'
                 end

      classes << 'hidden'
    end

    classes.join(' ')
  end

  def cell_style(result, _focus_areas, characteristic)
    return '' if result.blank?

    characteristic_data = result[characteristic.id.to_s]

    return '' if characteristic_data.blank?

    case characteristic_data['status']
    when 'actual' then "background-color: #{characteristic.focus_area.base_color}"
    when 'planned' then
      "background-color: #{lighten_color(characteristic.focus_area.base_color, 0.3)}"
    else
      # base_color = lighten_color(characteristic.focus_area.base_color, 0.2)
      # secondary_color = lighten_color(characteristic.focus_area.base_color, 0.7)

      if characteristic_data['status'] == 'checked' && characteristic_data['comment'].blank?
        "background: repeating-linear-gradient(
        45deg,
        transparent,
        transparent 1px,
        #{characteristic.focus_area.base_color} 1px,
        #{characteristic.focus_area.base_color} 2px
        );"
      else
        ''
      end
    end
  end

  def collection_for_linked_scorecard(parent_scorecard)
    return [] if parent_scorecard.blank?

    parent_scorecard
      .account
      .scorecards
      .where(linked_scorecard_id: [nil, parent_scorecard.linked_scorecard_id].uniq)
      .where.not(type: parent_scorecard.type)
      .order(:name)
      .pluck(:name, :id)
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

  private

  # Source: https://www.redguava.com.au/2011/10/lighten-or-darken-a-hexadecimal-color-in-ruby-on-rails/
  def lighten_color(hex_color, amount = 0.6)
    hex_color = hex_color.gsub('#', '')
    rgb = hex_color.scan(/../).map(&:hex)
    rgb[0] = [(rgb[0].to_i + (255 * amount)).round, 255].min
    rgb[1] = [(rgb[1].to_i + (255 * amount)).round, 255].min
    rgb[2] = [(rgb[2].to_i + (255 * amount)).round, 255].min
    '#%02x%02x%02x' % rgb
  end
end
