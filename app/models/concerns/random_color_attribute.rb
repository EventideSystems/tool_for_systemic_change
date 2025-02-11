# frozen_string_literal: true

# Set a random color for a model attribute
module RandomColorAttribute
  extend ActiveSupport::Concern

  included do
    attribute :color, default: -> { "##{SecureRandom.hex(3)}" }
  end
end
