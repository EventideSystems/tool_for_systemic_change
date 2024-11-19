# frozen_string_literal: true

# General helper methods for the application
module ApplicationHelper
  include Pagy::Frontend

  def application_title
    return 'Obsekio' if Rails.env.production?

    "Obsekio - #{Rails.env.titleize}"
  end

  def turbo_id_for(obj)
    obj.persisted? ? obj.id : obj.hash
  end

  # Render an SVG icon from views/icons
  # Source: https://www.writesoftwarewell.com/how-to-render-svg-icons-in-rails
  def render_icon(icon, classes: '')
    render "icons/#{icon}", classes:
  end

  def render_sidebar_item(title:, path:, icon:, active_group:, classes: '', count: nil) # rubocop:disable Metrics/ParameterLists
    active = active_group == controller.active_sidebar_item

    render 'layouts/shared/sidebar_item', title:, path:, icon:, active:, classes:, count:
  end

  def page_header_tag(title)
    content_tag :h1, title, class: 'text-2xl/8 font-semibold text-zinc-950 sm:text-xl/8 dark:text-white'
  end

  def form_header(resource)
    content_tag(:h3) do
      "#{form_title_lead(resource)}#{resource.class.model_name.human.titleize}"
    end
  end

  # SMELL: Defer to CSS for this in future
  def truncate_text(text, length = 50)
    safe_text = Nokogiri::HTML(text).text

    content_tag(
      :span,
      truncate(safe_text, length:),
      data: { toggle: 'tooltip', placement: 'bottom' },
      title: safe_text
    )
  end

  # SMELL: Defer to CSS for this in future
  def truncate_html(text, length = 25)
    return '' if text.blank?

    strip_tags(text.gsub('<br>', ' ').gsub(%r{</h\d>}, ' ')).truncate(length)
  end

  def import_files_instructions_link # rubocop:disable Metrics/MethodLength
    content_tag(:p, class: 'text-light-blue') do
      content_tag(:strong) do
        concat('For instructions on importing files go to ')
        concat(
          link_to(
            'www.wickedlab.co/importing-initiatives-organisations',
            'https://www.wickedlab.co/importing-initiatives-organisations',
            target: :_blank,
            style: 'text-decoration: underline;', rel: :noopener
          )
        )
        concat('.')
      end
    end
  end

  def import_comments_instructions_link # rubocop:disable Metrics/MethodLength
    content_tag(:p, class: 'text-light-blue') do
      content_tag(:strong) do
        concat('For instructions on importing files go to ')
        concat(
          link_to(
            'www.wickedlab.co/importing-comments-transition-cards',
            'https://www.wickedlab.co/importing-comments-transition-cards',
            target: :_blank,
            style: 'text-decoration: underline;', rel: :noopener
          )
        )
        concat('.')
      end
    end
  end

  def create_new_button(path)
    link_to(path, class: 'btn btn-primary') do
      safe_join([content_tag(:i, '', class: 'fa fa-plus'), ' Create New'])
    end
  end

  # TODO: Rename this
  def render_form_button(form)
    content_tag(:div, class: 'd-flex justify-content-end action-row') do
      concat(form.button(:submit, (form.object.new_record? ? 'Create' : 'Update').to_s, class: 'btn btn-primary'))
    end
  end

  def edit_button(title, path)
    content_tag(:div, class: 'd-flex justify-content-end action-row') do
      link_to(title, path, class: 'btn btn-primary')
    end
  end

  def render_date(date)
    return '<em>No data</em>'.html_safe unless date

    date.strftime('%B %-d, %Y')
  end

  def format_date(date)
    date.strftime('%F') if date.present?
  end

  private

  def form_title_lead(resource)
    return '' if resource.readonly?

    resource.new_record? ? 'New ' : 'Editing '
  end
end
