# frozen_string_literal: true

module DataModels
  # Reorder elements by position in a data model
  class RepositionElement
    def initialize(element:, new_position:, siblings:)
      @siblings = siblings
      @element = element
      @new_position = new_position.to_i
    end

    attr_reader :element, :new_position, :siblings

    # Reposition the element in its list of siblings
    #
    # @param element [ActiveRecord::Base] The element to reposition
    # @param new_position [Integer] The new position for the element (1-based index)
    # @param siblings [Array<ActiveRecord::Base>] The list of siblings to reorder (may or may not include the element)
    #
    # NOTE: This method does not persist the changes to the database. It only updates the positions in memory.
    #       You need to call `save!` on each element to persist the changes.
    #
    # @return [void]
    def self.call(element:, new_position:, siblings:)
      new(element:, new_position:, siblings:).call
    end

    def call
      ordered_siblings = (siblings - [element]).sort_by(&:position)

      ordered_siblings.insert(new_position - 1, element)

      element.position = new_position

      ordered_siblings.each_with_index do |sibling, index|
        sibling.position = index + 1
      end
    end
  end
end
