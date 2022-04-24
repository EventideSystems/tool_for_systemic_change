# frozen_string_literal: true

module TargetsNetworkMapHelper
  def options_for_targets_network_map_items(items)
    options_for_select(
      items.map do |item|
        [item.name, item.id]
      end.then do |options|
        options.unshift(%w[All all]) if options.present?
      end
    )
  end
end
