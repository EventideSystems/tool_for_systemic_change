# frozen_string_literal: true

class View < ApplicationRecord
  self.abstract_class = true

  def readonly?
    true
  end
end
