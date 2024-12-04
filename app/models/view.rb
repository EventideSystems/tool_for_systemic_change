# frozen_string_literal: true

# Base class for read-only database views.
#
# SMELL: This appears to cross over with the ApplicationView module.
class View < ApplicationRecord
  self.abstract_class = true

  def readonly?
    true
  end
end
