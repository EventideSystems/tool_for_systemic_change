module ScorecardsHelper
  def lookup_communities
    controller.current_account.communities
  end
  
  def lookup_organisations
    controller.current_account.organisations
  end
  
  def lookup_wicked_problems
    controller.current_account.wicked_problems
  end
  
  def display_selected_date
    return 'Select Date' if @selected_date.blank?
    Date.parse(@selected_date).strftime('%B %-d, %Y')
  end
end
