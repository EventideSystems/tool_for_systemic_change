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
end
