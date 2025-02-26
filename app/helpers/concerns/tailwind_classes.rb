# frozen_string_literal: true

require 'tailwind_merge'

# Common Tailwind CSS classes
module TailwindClasses
  extend ActiveSupport::Concern

  included do
    def merge_tailwind_class(base_classes, override_classes)
      TailwindMerge::Merger.new.merge([base_classes, override_classes])
    end
  end

  BORDER_CLASS = 'border-zinc-950/10 dark:border-white/10'

  DANGER_ZONE_BUTTON_CLASS = <<~CSS.squish
    rounded-md
    border
    dark:border-gray-600
    bg-zinc-950
    dark:bg-gray-800
    px-3
    py-2
    text-sm
    font-semibold
    text-white
    dark:text-red-600
    shadow-sm
    flex
    items-center
    space-x-2
    text-red-600
    hover:bg-red-500
    dark:hover:bg-red-500
    dark:border:hover:bg-red-500
    hover:text-white
    dark:hover:text-white
  CSS

  CHECK_BOX_CLASS = 'h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600'

  COMMON_FIELD_CLASS = <<~CSS.squish
    form-input
    w-full
    border
    border-gray-300
    rounded-md
    bg-white/5
    px-3
    py-1
    text-sm
    focus:ring-2
    focus:ring-blue-500
    dark:border-gray-600
    dark:text-white
  CSS

  SELECT_FIELD_CLASS = <<~CSS.squish.freeze
    py-1.5
    text-gray-900
    dark:text-white
    ring-inset
    ring-gray-300
    block
    w-full
    border
    rounded-md
    bg-white/5
    shadow-sm
    focus:ring-2
    focus:ring-inset
    focus:ring-blue-500
    sm:text-sm/6
    [&_*]:text-black
  CSS

  SUBMIT_BUTTON_CLASS = <<~CSS.squish
    rounded-md
    bg-zinc-950
    dark:bg-zinc-600
    px-3
    py-2
    text-sm
    font-semibold
    text-white
    shadow-sm
    hover:bg-zinc-400
    focus-visible:outline
    focus-visible:outline-2
    focus-visible:outline-offset-2
    focus-visible:outline-zinc-500
    cursor-pointer
  CSS

  TEXT_FIELD_CLASS = COMMON_FIELD_CLASS
  TEXT_AREA_CLASS = COMMON_FIELD_CLASS
  DATE_FIELD_CLASS = "#{COMMON_FIELD_CLASS} mt-2 dark:[color-scheme:dark]".freeze

  ERROR_BORDER_CLASS = 'border-2 border-red-500'
  ERROR_MESSAGE_CLASS = 'h-2 mt-2 mb-4 text-xs text-red-500 dark:text-red-500'
  LABEL_CLASS = 'block text-sm font-medium leading-6 text-gray-900 dark:text-white'
end
