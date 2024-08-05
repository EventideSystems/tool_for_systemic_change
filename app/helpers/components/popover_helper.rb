# frozen_string_literal: true

module Components
  # Shadcn-styled popver menu helper
  module PopoverHelper
    def render_popover(**options, &block)
      content = capture(&block) if block
      render 'components/ui/popover', content:, **options
    end

    def popover_trigger(&block)
      content_for :popover_trigger, capture(&block), flush: true
    end

    def popover_content(options = {}, &block)
      content_for :popover_content_class, options[:class], flush: true
      content_for :popover_content, capture(&block), flush: true
    end
  end
end
