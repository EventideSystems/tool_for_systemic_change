# frozen_string_literal: true

# Support for data elements in the application
# This module provides shared functionality for data elements such as FocusAreaGroup, FocusArea, and Characteristic.
# It includes methods to retrieve siblings and construct full names based on code and short name.
#
# NOTE: This module expects the including class to have a `parent` method that returns the parent object.
# The `parent` method should return an object that responds to `children`.
#
# @see FocusAreaGroup
# @see FocusArea
# @see Characteristic
#
module DataElementable
  extend ActiveSupport::Concern

  included do
    # Any shared logic or callbacks can go here if needed
  end

  def siblings
    parent.children - [self]
  end

  def full_name
    [code, short_name.presence || name].compact_blank.join(' ')
  end
end
