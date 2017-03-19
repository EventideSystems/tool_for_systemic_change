module ApplicationHelper

  def bootstrap_class_for flash_type
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-error"
    when :alert
      "alert-warning"
    when :notice
      "alert-info"
    else
      flash_type
    end
  end
  
  def form_title(resource)
    "#{form_title_lead(resource)}#{resource.class.name.titleize}"
  end
  
  def form_title_lead(resource)
    return '' if resource.readonly?
    resource.new_record? ? 'New ' : 'Editing '
  end
  
  def action_icon(action)
    case action.to_sym
    when :show
      "fa-eye"
    end
  end
  
  def current_account
    controller.current_account
  end

end