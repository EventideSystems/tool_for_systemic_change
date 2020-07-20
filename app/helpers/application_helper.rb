module ApplicationHelper

  def application_title
    return "WickedLab" if Rails.env.production?
    "WickedLab - #{Rails.env.titleize}" 
  end

  # TODO Delete - no longer in use
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
  
  def form_header(resource)
    content_tag(:h3) do
      "#{form_title_lead(resource)}#{resource.class.model_name.human.titleize}"
    end
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
          'https://www.wickedlab.com.au/help-importing-files', 
          target: :_blank, style: 'text-decoration: underline;'
        )
        concat "."
      end
    end  
  end
  
  def import_comments_instructions_link
    content_tag(:p, class: 'text-light-blue') do 
      content_tag(:strong) do
        concat "For instructions on importing files go to "
        concat link_to(
          'www.wickedlab.com.au/help-importing-comments',
          'https://www.wickedlab.com.au/help-importing-comments.html', 
          target: :_blank, style: 'text-decoration: underline;'
        )
        concat "."
      end
    end  
  end

  def create_new_button(path) 
    link_to(path, class: 'btn btn-primary') do
      safe_join([content_tag(:i, '', class: "fa fa-plus"), ' Create New'])
    end
  end
  
  # TODO Rename this
  def render_form_button(form)
    content_tag(:div, class: 'd-flex justify-content-end action-row') do
      concat form.button :submit, "#{form.object.new_record? ? 'Create' : 'Update'}",  class: 'btn btn-primary'
    end
  end

  def edit_button(title, path)
    content_tag(:div, class: 'd-flex justify-content-end action-row') do
      link_to title, path, class: 'btn btn-primary'
    end
  end
  
  def render_date(date)
    return '<em>No data</em>'.html_safe unless date
    date.strftime('%B %-d, %Y')
  end
end
