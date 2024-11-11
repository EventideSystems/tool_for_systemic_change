# frozen_string_literal: true

# Utility module for read-only database views.
#
# SMELL: This is a concern that should be included in all view models, though there appears to be cross over
# with the View class. This should be refactored to be more DRY.
module ApplicationView
  extend ActiveSupport::Concern

  included do
    def readonly?
      true
    end
  end
end
