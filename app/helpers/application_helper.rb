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
  
  def pluralize_without_count(count, noun, text=nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end
  
  def truncate_text(text, length=50)
    safe_text = Nokogiri::HTML(text).text
    
    content_tag(
      :span, 
      truncate(safe_text, length: length), 
      data: { toggle: "tooltip", placement: "bottom" }, title: safe_text
    )
  end
  
  def import_files_instructions_link
    content_tag(:p, class: 'text-light-blue') do 
      content_tag(:strong) do
        concat "For instructions on importing files go to "
        concat link_to(
          'www.wickedlab.com.au/help-importing-files',
          'http://www.wickedlab.com.au/help-importing-files', 
          target: :_blank, style: 'text-decoration: underline;'
        )
        concat "."
      end
    end  
  end  
end