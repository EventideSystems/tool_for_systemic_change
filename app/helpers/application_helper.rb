module ApplicationHelper

  def application_title
    return "WickedLab" if Rails.env.production?
    "WickedLab - #{Rails.env.titleize}"
  end

  def form_header(resource)
    content_tag(:h3) do
      "#{form_title_lead(resource)}#{resource.class.model_name.human.titleize}"
    end
  end

  # SMELL: Defer to CSS for this in future
  def truncate_text(text, length=50)
    safe_text = Nokogiri::HTML(text).text

    content_tag(
      :span,
      truncate(safe_text, length: length),
      data: { toggle: "tooltip", placement: "bottom" }, title: safe_text
    )
  end

  # SMELL: Defer to CSS for this in future
  def truncate_html(text, length=25)
    return '' unless text.present?

    strip_tags(
      text.gsub('<br>', ' ').gsub(/<\/h\d>/, ' ')
    ).truncate(length)
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

  private

  def form_title_lead(resource)
    return '' if resource.readonly?
    resource.new_record? ? 'New ' : 'Editing '
  end
end
