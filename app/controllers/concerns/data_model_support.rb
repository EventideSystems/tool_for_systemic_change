# frozen_string_literal: true

# Common functionality for data model support
module DataModelSupport
  extend ActiveSupport::Concern

  DATA_MODEL_ELEMENT_PARAMS = %i[
    code
    color
    description
    name
    position
    short_name
  ].freeze
end
