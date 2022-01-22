# frozen_string_literal: true

module ScorecardsHelper

  ACTUAL_OR_PLANNED =  %w[actual planned].freeze

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

  def cell_class(result, focus_areas, characteristic)
    classes = ['cell']

    characteristic_data = result[characteristic.id.to_s]

    if characteristic_data['status'].in?(ACTUAL_OR_PLANNED) && characteristic_data['comment'].present?
      classes << [
        "#{characteristic_data['status']}#{@focus_areas.index(characteristic.focus_area)+1}",
        characteristic_data['status']
      ]

      classes << 'hidden' unless characteristic_data['status'] == 'actual'
    else
      if characteristic_data['checked']
        classes << [
          "checked#{@focus_areas.index(characteristic.focus_area)+1}",
          "checked"
        ]
      end

      if characteristic_data['checked'] && characteristic_data['comment'].blank?
        classes << 'no-comment'
      else
        classes << 'gap'
      end

      classes << 'hidden'
    end

    classes.join(' ')
  end
end
