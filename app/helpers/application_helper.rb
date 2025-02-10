# frozen_string_literal: true

# General helper methods for the application
module ApplicationHelper
  include Pagy::Frontend
  include TailwindClasses

  def application_title
    return 'Obsekio' if Rails.env.production?

    "Obsekio - #{Rails.env.titleize}"
  end

  def page_header_tag(title)
    content_tag :h1, title, class: 'text-2xl/8 font-semibold text-zinc-950 sm:text-xl/8 dark:text-white'
  end

  def horizontal_rule(options = {})
    options[:class] = merge_tailwind_class("w-full border-t #{BORDER_CLASS}", options[:class])
    options[:role] = 'presentation'

    content_tag(:hr, nil, options)
  end

  # <hr role="presentation" class="my-10 mt-6 w-full border-t border-zinc-950/10 dark:border-white/10">

  # def turbo_id_for(obj)
  #   obj.persisted? ? obj.id : obj.hash
  # end

  # Render an SVG icon from views/icons
  # Source: https://www.writesoftwarewell.com/how-to-render-svg-icons-in-rails
  def render_icon(icon, classes: '')
    render "icons/#{icon}", classes:
  end

  def render_sidebar_item(title:, path:, icon:, active_group:, classes: '', count: nil) # rubocop:disable Metrics/ParameterLists
    active = active_group == controller.active_sidebar_item

    render 'layouts/shared/sidebar_item', title:, path:, icon:, active:, classes:, count:
  end

  def render_tab_item(title:, path:, active_tab:, classes: '')
    active = active_tab == controller.active_tab_item

    render 'layouts/shared/tab_item', title:, path:, active:, classes:
  end

  def definition_list_element(term, definition)
    render 'application/definition_list_element', term: term, definition: definition
  end

  # def import_files_instructions_link
  #   content_tag(:p, class: 'text-light-blue') do
  #     content_tag(:strong) do
  #       concat('For instructions on importing files go to ')
  #       concat(
  #         link_to(
  #           'www.wickedlab.co/importing-initiatives-organisations',
  #           'https://www.wickedlab.co/importing-initiatives-organisations',
  #           target: :_blank,
  #           style: 'text-decoration: underline;', rel: :noopener
  #         )
  #       )
  #       concat('.')
  #     end
  #   end
  # end

  # def import_comments_instructions_link
  #   content_tag(:p, class: 'text-light-blue') do
  #     content_tag(:strong) do
  #       concat('For instructions on importing files go to ')
  #       concat(
  #         link_to(
  #           'www.wickedlab.co/importing-comments-transition-cards',
  #           'https://www.wickedlab.co/importing-comments-transition-cards',
  #           target: :_blank,
  #           style: 'text-decoration: underline;', rel: :noopener
  #         )
  #       )
  #       concat('.')
  #     end
  #   end
  # end
end
