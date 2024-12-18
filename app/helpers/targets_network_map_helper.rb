# frozen_string_literal: true

# Helper for SDG target network map
module TargetsNetworkMapHelper
  def options_for_targets_network_map_items(items)
    return [] if items.blank?

    options_for_select(
      items.map do |item|
        [item.name, item.id]
      end.then do |options| # rubocop:disable Style/MultilineBlockChain
        options.unshift(%w[All all]) if options.present?
      end
    )
  end
end
