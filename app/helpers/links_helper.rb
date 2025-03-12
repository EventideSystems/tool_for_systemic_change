# frozen_string_literal: true

# Helper for links
module LinksHelper
  include TailwindClasses

  # rubocop:disable Layout/LineLength
  PRIMARY_CLASS = 'relative isolate inline-flex items-center justify-center gap-x-2 rounded-lg border border-zinc-500 text-sm font-semibold rounded-md bg-zinc-950 dark:bg-zinc-600 px-3 py-1 font-semibold text-white shadow-sm hover:bg-zinc-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-500 whitespace-nowrap'
  SECONDARY_CLASS = 'rounded-md border border-gray-500 bg-white dark:bg-zinc-950 px-3 py-2 text-sm font-semibold text-zinc-950 dark:text-white shadow-sm hover:bg-zinc-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-500 whitespace-nowrap'
  EXTERNAL_LINK_CLASS = 'text-blue-500 hover:text-blue-700 underline'
  LANDING_PAGES_LINK_CLASS = 'text-orange-300 hover:text-orange-500 dark:text-orange-300 dark:hover:text-orange-500'
  # rubocop:enable Layout/LineLength

  def button_to_primary(text, url, options = {})
    button_to(text, url, options.merge(class: PRIMARY_CLASS))
  end

  def link_to_primary(text, url, options = {})
    link_to(text, url, options.merge(class: PRIMARY_CLASS))
  end

  def link_to_external_url(url)
    return '' if url.blank?

    begin
      domain = URI.parse(url).host
      return '' if domain.blank?
    rescue URI::InvalidURIError
      return "Invalid URL: '#{url}'"
    end

    link_to domain, url, target: '_blank', rel: 'noopener', alt: url, class: EXTERNAL_LINK_CLASS
  end

  def landing_pages_link_to(text, url, options = {})
    link_to(text, url, class: merge_tailwind_class(LANDING_PAGES_LINK_CLASS, options[:class]))
  end
end
