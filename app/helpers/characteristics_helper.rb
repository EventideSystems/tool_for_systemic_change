# frozen_string_literal: true

# Helper methods for presenting characteristics
module CharacteristicsHelper
  def sanitized_characteristic_description(characteristic)
    sanitize(
      characteristic.description,
      tags: %w[h1 br strong em a],
      attributes: %w[href target]
    )
  end
end
