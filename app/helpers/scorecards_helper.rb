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

    if result.dig(characteristic.id.to_s, 'status').in? ['actual', 'planned']
      classes << "#{result.dig(characteristic.id.to_s, 'status')}#{@focus_areas.index(characteristic.focus_area)+1}"      
    else
      if result.dig(characteristic.id.to_s, 'checked')
        classes << "checked#{@focus_areas.index(characteristic.focus_area)+1}"
      else
        classes << 'gap'
      end
    end

    classes.join(' ')
  end
end
