# frozen_string_literal: true

# Ensure that the code is unique within the impact card data model.
module ValidateUniqueCode
  extend ActiveSupport::Concern

  included do
    validate :unique_code_within_data_model

    private

    def unique_code_within_data_model
      return true if code.blank?
      return true if data_model.element_by_code(code) == self

      errors.add(:code, 'is already taken in this data model') if data_model.codes.include?(code)
    end
  end
end
