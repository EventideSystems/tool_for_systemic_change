# frozen_string_literal: true

require 'tailwind_merge'

# Custom FormBuilder adding Tailwind classes to form fields.
class CustomFormBuilder < ActionView::Helpers::FormBuilder
  BASE_COLOR_CLASSES = %w[
    bg-red-500
    bg-orange-500
    bg-amber-500
    bg-yellow-500
    bg-lime-500
    bg-green-500
    bg-emerald-500
    bg-teal-500
    bg-cyan-500
    bg-sky-500
    bg-blue-500
    bg-indigo-500
    bg-violet-500
    bg-purple-500
    bg-fuchsia-500
    bg-pink-500
    bg-rose-500
  ].freeze

  BASE_COLOR_SELECT_DATA_ATTRIBUTES = {
    action: 'base-color-select#change',
    base_color_select_target: 'select'
  }.freeze

  OPTIONS_FOR_BASE_COLOR_SELECT = \
    BASE_COLOR_CLASSES.map do |color_class|
      color_name = color_class.split('-').second
      [color_name.capitalize, color_name, { class: color_class }]
    end


  # rubocop:disable Layout/LineLength
  CHECK_BOX_CLASS = 'h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600'
  SUBMIT_BUTTON_CLASS = 'rounded-md bg-zinc-950 dark:bg-zinc-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-zinc-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-500'

  COMMON_FIELD_CLASS = 'block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 sm:text-sm sm:leading-6'

  TEXT_FIELD_CLASS = "#{COMMON_FIELD_CLASS} bg-white/5 bg-opacity-5 bg-green-400 dark:text-white dark:ring-white/10 focus:ring-2 focus:ring-inset focus:ring-blue-500"
  TEXT_AREA_CLASS = "#{COMMON_FIELD_CLASS} bg-white/5 dark:text-white placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-500"
  SELECT_FIELD_CLASS = "#{COMMON_FIELD_CLASS} mt-2 pl-3 pr-10 focus:ring-2 focus:ring-yellow-500"

  # TEXT_FIELD_CLASS = 'block w-full rounded-md border-0 bg-white/5 py-1.5 text-gray-900 dark:text-white shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-white/10 focus:ring-2 focus:ring-inset focus:ring-yellow-500 sm:text-sm sm:leading-6'
  # TEXT_AREA_CLASS = 'block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-yellow-600 sm:text-sm sm:leading-6'
  # SELECT_FIELD_CLASS = 'mt-2 block w-full rounded-md border-0 py-1.5 pl-3 pr-10 text-gray-900 ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-yellow-500 sm:text-sm sm:leading-6'
  # rubocop:enable Layout/LineLength
  ERROR_BORDER_CLASS = 'border-2 border-red-500'
  LABEL_CLASS = 'block text-sm font-medium leading-6 text-gray-900 dark:text-white'

  def check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
    default_opts = { class: build_default_field_class(CHECK_BOX_CLASS, ERROR_BORDER_CLASS, method) }
    merged_opts = default_opts.merge(options)

    @template.content_tag(:div) do
      @template.concat(super(method, merged_opts, checked_value, unchecked_value))
      append_error_message(@object, method)
    end
  end

  def label(method, content_or_options = nil, options = {}, &block)
    options_class = content_or_options.is_a?(Hash) ? content_or_options.delete(:class) : options.delete(:class)
    label_class = tailwind_merge(LABEL_CLASS, options_class)
    default_opts = { class: label_class }
    merged_opts = default_opts.merge(options)
    super(method, content_or_options , merged_opts, &block)
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    default_html_options = { class: build_default_field_class(SELECT_FIELD_CLASS, ERROR_BORDER_CLASS, method) }
    merged_html_options = default_html_options.merge(html_options)

    @template.content_tag(:div) do
      @template.concat(super(method, choices, options, merged_html_options, &block))
      append_error_message(@object, method)
    end
  end

  def submit(value = nil, options = {})
    default_opts = { class: SUBMIT_BUTTON_CLASS }
    merged_opts = default_opts.merge(options)
    super(value, merged_opts)
  end

  def text_area(method, options = {})
    options_class = options.delete(:class)
    text_area_class = tailwind_merge(TEXT_AREA_CLASS, options_class)

    default_opts = { class: build_default_field_class(text_area_class, ERROR_BORDER_CLASS, method) }
    merged_opts = default_opts.merge(options)

    @template.content_tag(:div) do
      @template.concat(super(method, merged_opts))
      append_error_message(@object, method)
    end
  end

  def text_field(method, options = {})
    default_opts = { class: build_default_field_class(TEXT_FIELD_CLASS, ERROR_BORDER_CLASS, method) }
    merged_opts = default_opts.merge(options)

    @template.content_tag(:div) do
      @template.concat(super(method, merged_opts))
      append_error_message(@object, method)
    end
  end

  def base_color_select(method, options = {}, html_options = {}, &block)
    field_classes = "#{SELECT_FIELD_CLASS} bg-#{@object.send(method)}-500"
    default_html_options = {
      class: build_default_field_class(field_classes, ERROR_BORDER_CLASS, method),
      data: BASE_COLOR_SELECT_DATA_ATTRIBUTES
    }
    merged_html_options = default_html_options.merge(html_options)

    @template.content_tag(:div, data: { controller: 'base-color-select' }) do
      select(method, OPTIONS_FOR_BASE_COLOR_SELECT, options, merged_html_options, &block)
    end
  end

  private

  def append_error_message(object, method)
    return unless object.errors[method].any?

    object.errors[method].each do |error_message|
      @template.concat(
        @template.content_tag(:div, class: 'h-2 mt-2 mb-4 text-xs text-red-500 dark:text-red-500') do
          error_message.html_safe # rubocop:disable Rails/OutputSafety
        end
      )
    end
  end

  def build_default_field_class(base_class, error_class, method)
    base_class + (@object.errors[method].any? ? " #{error_class}" : '')
  end

  def tailwind_merge(base_classes, override_classes)
    TailwindMerge::Merger.new.merge([base_classes, override_classes])
  end
end
