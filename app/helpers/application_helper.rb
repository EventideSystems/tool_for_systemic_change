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
    lead = resource.new_record? ? 'New' : 'Editing'
    "#{lead} #{resource.class.name.titleize}"
  end

end