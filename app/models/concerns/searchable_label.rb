# frozen_string_literal: true

module SearchableLabel
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      %w[name description] + _ransackers.keys
    end

    def ransackable_associations(auth_object = nil)
      []
    end
  end
end
