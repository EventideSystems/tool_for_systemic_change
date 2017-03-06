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
end
