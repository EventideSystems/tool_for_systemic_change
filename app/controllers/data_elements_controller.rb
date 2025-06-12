# frozen_string_literal: true

# Base controller for the data elements (goals, targets, indicators)
class DataElementsController < ApplicationController
  private

  def fallback_position(parent)
    (parent.children.maximum(:position) || 0) + 1
  end

  def next_position(siblings)
    siblings.maximum(:position).to_i + 1
  end

  def delete_element(element)
    siblings = element.siblings

    ActiveRecord::Base.transaction do
      siblings.each_with_index { |sibling, index| sibling.update_attribute(:position, index + 1) } # rubocop:disable Rails/SkipsModelValidations
      element.delete
    end
  end

  # Save the element and its siblings, ensuring that the position is updated correctly
  # and that the transaction is handled properly.
  def save_element(element, new_position)
    siblings = element.siblings

    DataModels::RepositionElement.call(element:, new_position:, siblings:)

    ActiveRecord::Base.transaction do
      siblings.each { |sibling| sibling.update_attribute(:position, sibling.position) } # rubocop:disable Rails/SkipsModelValidations
      element.save
    end
  end

  DATA_MODEL_ELEMENT_PARAMS = %i[
    code
    color
    description
    name
    position
    short_name
  ].freeze
end
