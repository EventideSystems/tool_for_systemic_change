# frozen_string_literal: true

# Custom FormBuilder adding Tailwind classes to form fields.
class CustomFormBuilder < ActionView::Helpers::FormBuilder # rubocop:disable Metrics/ClassLength
  include TailwindClasses

  # BASE_COLOR_CLASSES = %w[
  #   bg-red-500
  #   bg-orange-500
  #   bg-amber-500
  #   bg-yellow-500
  #   bg-lime-500
  #   bg-green-500
  #   bg-emerald-500
  #   bg-teal-500
  #   bg-cyan-500
  #   bg-sky-500
  #   bg-blue-500
  #   bg-indigo-500
  #   bg-violet-500
  #   bg-purple-500
  #   bg-fuchsia-500
  #   bg-pink-500
  #   bg-rose-500
  # ].freeze

  # BASE_COLOR_SELECT_DATA_ATTRIBUTES = {
  #   action: 'base-color-select#change',
  #   base_color_select_target: 'select'
  # }.freeze

  # OPTIONS_FOR_BASE_COLOR_SELECT = \
  #   BASE_COLOR_CLASSES.map do |color_class|
  #     color_name = color_class.split('-').second
  #     [color_name.capitalize, color_name, { class: color_class }]
  #   end

  MULTI_SELECT_OPTION_TEMPLATE = <<~HTML
    <div class="flex justify-between items-center w-full">
      <div class="flex">
        <div data-icon></div>
        <div data-title></div>
      </div>
      <div data-select-icon class="hidden hs-selected:block">
        <svg
          class="shrink-0 size-3.5 text-blue-600 dark:text-blue-500 "
          xmlns="http:.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
    </div>
  HTML

  MULTI_SELECT_TOGGLE_CLASSES = %w[
    hs-select-disabled:pointer-events-none
    hs-select-disabled:opacity-50
    mt-2
    relative
    py-1.5
    px-3
    pe-9
    flex
    text-nowrap
    w-auto
    cursor-pointer
    bg-white
    border
    border-gray-300
    rounded-lg
    text-start
    text-sm
    focus:ring-2
    focus:ring-blue-500
    before:absolute
    before:inset-0
    before:z-[1]
    dark:bg-neutral-900
    dark:border-gray-600
    dark:text-neutral-400
  ].join(' ').freeze

  MULTI_SELECT_DROPDOWN_CLASSES = %w[
    mt-2
    z-50
    w-full
    max-h-100
    p-1
    space-y-0.5
    bg-white
    border
    border-gray-200
    rounded-lg
    overflow-hidden
    overflow-y-auto
    [&::-webkit-scrollbar]:w-2
    [&::-webkit-scrollbar-thumb]:rounded-full
    [&::-webkit-scrollbar-track]:bg-gray-100
    [&::-webkit-scrollbar-thumb]:bg-gray-300
    dark:[&::-webkit-scrollbar-track]:bg-neutral-700
    dark:[&::-webkit-scrollbar-thumb]:bg-neutral-500
    dark:bg-neutral-900
    dark:border-neutral-700
  ].join(' ').freeze

  MULTI_SELECT_OPTION_CLASSES = %w[
    hs-selected:block
    py-2
    px-4
    w-full
    text-sm
    text-gray-800
    cursor-pointer
    hover:bg-gray-100
    rounded-lg
    focus:outline-none
    focus:bg-gray-100
    dark:bg-neutral-900
    dark:hover:bg-neutral-800
    dark:text-neutral-200
    dark:focus:bg-neutral-800
  ].join(' ').freeze

  MULTI_SELECT_EXTRA_MARKUP = <<~HTML
    <div class="absolute top-6 end-3 -translate-y-1/2">
      <svg
        class="shrink-0 size-3.5 text-gray-500 dark:text-neutral-500 "
        xmlns="http://www.w3.org/2000/svg"
        width="20"
        height="20"
        viewBox="0 0 20 20"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <path d="m7 15 5 5 5-5"/><path d="m7 9 5-5 5 5"/>
      </svg>
    </div>
  HTML

  MULTI_SELECT_BUTTON_CLASS = %w[
    mt-2
    ml-1
    w-auto
    h-auto
    px-1.5
    border
    border-gray-300
    rounded-lg
    dark:border-gray-600
    rounded-md
    text-gray-500
    dark:text-neutral-500
    flex
    items-center
    justify-center
  ].join(' ')

  MULTI_SELECT_DEFAULT_HS_SELECT = {
    placeholder: 'Select multiple options...',
    toggleTag: '<button type="button" aria-expanded="false"></button>',
    toggleClasses: MULTI_SELECT_TOGGLE_CLASSES,
    # toggleSeparators: {
    #   betweenItemsAndCounter: '&'
    # },
    toggleCountText: 'selected',
    # toggleCountTextMinItems: 3,
    # toggleCountTextMode: 'nItemsAndCount',
    dropdownClasses: MULTI_SELECT_DROPDOWN_CLASSES,
    optionClasses: MULTI_SELECT_OPTION_CLASSES,
    optionTemplate: MULTI_SELECT_OPTION_TEMPLATE,
    extraMarkup: MULTI_SELECT_EXTRA_MARKUP
  }.freeze

  def check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
    merge_options = merge_options(method:, options:, default_class: CHECK_BOX_CLASS)
    wrap_field(method) { super(method, merge_options, checked_value, unchecked_value) }
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {}) # rubocop:disable Metrics/ParameterLists
    merged_html_options = merge_options(method: method, options: html_options, default_class: SELECT_FIELD_CLASS)
    wrap_field(method) { super(method, collection, value_method, text_method, options, merged_html_options) }
  end

  # TODO: Add 'dark:[color-scheme:dark]' to the end of the class string to support dark mode.
  def date_field(method, options = {})
    # wrap_field(method) { super(method, merge_options(method:, options:)) }

    # TODO: Sketch of possible future implementation
    options = merge_options(method:, options:, default_class: DATE_FIELD_CLASS)

    @template.content_tag(:div, class: 'flex', data: { controller: 'date-select' }) do
      @template.concat(super(method, merge_options(method:, options:)))
      @template.concat(build_clear_button('date-select'))
    end
  end

  def email_field(method, options = {})
    wrap_field(method) { super(method, merge_options(method:, options:)) }
  end

  def label(method, content_or_options = nil, options = nil, &block)
    label_class_from_content = content_or_options.is_a?(Hash) ? content_or_options.delete(:class) : nil
    label_class_from_options = options.is_a?(Hash) ? options.delete(:class) : nil
    label_class = label_class_from_content || label_class_from_options

    tailwind_options = { class: merge_tailwind_class(LABEL_CLASS, label_class) }
    merge_options = options.is_a?(Hash) ? options.merge(tailwind_options) : tailwind_options

    super(method, content_or_options, merge_options, &block)
  end

  def multi_select(method, choices = nil, options = {}, html_options = {}, &block) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    placeholder = options.delete(:placeholder) || 'Select multiple options...'
    # rubocop:disable Naming/VariableName
    toggleCountText = multi_select_toggle_count_text(method)
    hs_select = MULTI_SELECT_DEFAULT_HS_SELECT.merge(placeholder:, toggleCountText:).to_json
    # rubocop:enable Naming/VariableName

    choices = '<option disabled="">No options available</option>'.html_safe if choices.empty?
    options[:multiple] = true
    data_options = html_options.delete(:data) || {}
    html_options[:data] = data_options.merge({ multi_select_target: 'select', hs_select: })
    html_options[:class] = 'hidden'

    @template.content_tag(:div, class: 'flex', data: { controller: 'multi-select' }) do
      @template.concat(ActionView::Helpers::Tags::Select.new(
        @object, method, @template, choices, options, html_options, &block
      ).render)
      @template.concat(build_clear_button('multi-select'))
    end
  end

  def number_field(method, options = {})
    wrap_field(method) { super(method, merge_options(method:, options:)) }
  end

  def password_field(method, options = {})
    wrap_field(method) { super(method, merge_options(method:, options:)) }
  end

  def rich_textarea(method, options = {})
    wrap_field(method) { super(method, merge_options(method:, options:)) }
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    merged_html_options = merge_options(method:, options: html_options, default_class: SELECT_FIELD_CLASS)

    wrap_field(method) { super(method, choices, options, merged_html_options, &block) }
  end

  def submit(value = nil, options = {})
    super(value, merge_options(method: nil, options:, default_class: SUBMIT_BUTTON_CLASS))
  end

  def text_area(method, options = {})
    wrap_field(method) { super(method, merge_options(method:, options:, default_class: TEXT_AREA_CLASS)) }
  end

  def text_field(method, options = {})
    wrap_field(method) { super(method, merge_options(method:, options:, default_class: TEXT_AREA_CLASS)) }
  end

  # def base_color_select(method, options = {}, html_options = {}, &block)
  #   field_classes = "#{SELECT_FIELD_CLASS} bg-#{@object.send(method)}-500"
  #   default_html_options = {
  #     class: build_default_field_class(field_classes, ERROR_BORDER_CLASS, method),
  #     data: BASE_COLOR_SELECT_DATA_ATTRIBUTES
  #   }
  #   merged_html_options = default_html_options.merge(html_options)

  #   @template.content_tag(:div, data: { controller: 'base-color-select' }) do
  #     select(method, OPTIONS_FOR_BASE_COLOR_SELECT, options, merged_html_options, &block)
  #   end
  # end

  private

  def append_error_message(object, method)
    return unless object.errors[method].any?

    object.errors[method].each do |error_message|
      @template.concat(
        @template.content_tag(:div, class: ERROR_MESSAGE_CLASS) do
          error_message.html_safe # rubocop:disable Rails/OutputSafety
        end
      )
    end
  end

  def build_clear_button(stimulus_controller) # rubocop:disable Metrics/MethodLength
    <<~HTML.html_safe # rubocop:disable Rails/OutputSafety
      <button
        type="button"
        title="Clear filter"
        class="#{MULTI_SELECT_BUTTON_CLASS}"
        data-#{stimulus_controller}-target="clear"
      >
        <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor">
          <path d="m256-200-56-56 224-224-224-224 56-56 224 224 224-224 56 56-224 224 224 224-56 56-224-224-224 224Z"></path>
        </svg>
      </button>
    HTML
  end

  def build_default_field_class(base_class, error_class, method)
    return base_class if method.blank?
    return base_class if @object.blank?

    base_class + (@object.errors[method].any? ? " #{error_class}" : '')
  end

  def merge_options(method:, options: {}, default_class: TEXT_FIELD_CLASS, error_class: ERROR_BORDER_CLASS)
    options_class = options.delete(:class)
    text_field_class = merge_tailwind_class(default_class, options_class)

    base_options = { class: build_default_field_class(text_field_class, error_class, method) }
    base_options.merge(options)
  end

  def multi_select_toggle_count_text(method)
    base_text = method.to_s.titleize.downcase.singularize
    pluralized_text = base_text.pluralize

    diff = pluralized_text.gsub(base_text, '')

    "#{base_text}(#{diff}) selected"
  end

  def wrap_field(method)
    @template.content_tag(:div) do
      @template.concat(yield)
      append_error_message(@object, method)
    end
  end
end
