module UsersHelper
  
  def current_user_name
    return '' unless user_signed_in?
    return current_user.email unless current_user.name.present?
    current_user.name
  end
  
  def current_user_membership_summary
    return '' unless user_signed_in?
    "Member since #{current_user.created_at}"
  end
  
end
