# frozen_string_literal: true

module Components
  # Helper for rendering toast messages
  module ToastHelper
    def render_toast(header: nil, description: nil, action: nil, data: {}, variant: :default, **options) # rubocop:disable Metrics/ParameterLists
      options[:class] ||= ''

      if variant == :destructive
        options[:class] << ' destructive group border-destructive bg-destructive text-destructive-foreground '
      end

      render 'components/ui/toast', header:, description:, action:, class:, data:, options:
    end
  end
end
