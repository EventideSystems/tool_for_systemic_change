# frozen_string_literal: true

# Basic search module for models
# Usage:
# class Model < ApplicationRecord
#   include Searchable
# end
# Model.ransack(params[:q]).result
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      %w[name description] + _ransackers.keys
    end

    def ransackable_associations(_auth_object = nil)
      []
    end
  end
end
