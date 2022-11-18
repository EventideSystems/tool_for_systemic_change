# frozen_string_literal: true

module ApplicationView
  extend ActiveSupport::Concern

  included do
    def readonly?
      true
    end
  end
end
