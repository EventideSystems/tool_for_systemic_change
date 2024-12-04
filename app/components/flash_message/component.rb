# frozen_string_literal: true

module FlashMessage
  # Simple flash message component
  class Component < ViewComponent::Base
    include Components::ToastHelper

    attr_reader :type, :message

    def initialize(type:, message:)
      @type = type
      @message = message
      super
    end

    def header = type
    def description = message

    def color_classes
      COLOR_CLASSES[type.to_sym]
    end

    COLOR_CLASSES = {
      success: 'bg-green-50 text-green-800',
      error: 'text-red-800 bg-red-500 dark:bg-gray-800 dark:text-red-400',
      warning: 'text-yellow-800 bg-yellow-500 dark:bg-gray-800 dark:text-yellow-300',
      notice: 'bg-green-500 text-green-800',
      default: 'bg-gray-50 dark:bg-gray-800',
      alert: 'text-red-800 bg-red-500 dark:bg-gray-800 dark:text-red-400'
    }.freeze
  end
end
