# frozen_string_literal: true

# Base class for all database-backed models
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    # Public: Create string-based enum
    # TODO: Change this to follow the same pattern as the integer enum in Rails 8 (e.g.
    #   string_enum :status, %i[actual planned more_information suggestion]
    def string_enum(definitions)
      definitions.each do |name, values|
        enum name, string_enum_values(values)
      end
    end

    private

    def string_enum_values(values)
      values.to_h { |value| [value.to_sym, value.to_s] }
    end
  end
end
