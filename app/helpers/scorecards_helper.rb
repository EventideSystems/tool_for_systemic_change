module ScorecardsHelper
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

    if characteristic_data['status'].in? ['actual', 'planned']
      classes << [
        "#{characteristic_data['status']}#{@focus_areas.index(characteristic.focus_area)+1}",
        characteristic_data['status']
      ]
    else
      if characteristic_data['checked']
        classes << [
          "checked#{@focus_areas.index(characteristic.focus_area)+1}",
          "checked"
        ]
      else
        classes << 'gap'
      end

      classes << 'no-comment' if characteristic_data['comment'].blank?
    end

    classes << 'hidden' unless characteristic_data['status'] == 'actual'

    classes.join(' ')
  end
end
