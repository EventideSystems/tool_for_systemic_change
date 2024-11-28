# frozen_string_literal: true

namespace :impact_cards do
  desc 'Deep copy impact cards'
  task deep_copy: :environment do
    puts 'Deep copying impact card...'

    if ENV['IMPACT_CARD_ID'].nil?
      puts 'IMPACT_CARD_ID is required'
      puts 'Usage: rake impact_cards:deep_copy IMPACT_CARD_ID=1 [NEW_NAME="New name"] [TARGET_ACCOUNT_ID=1]'
      exit(1)
    end

    impact_card = Scorecard.find(ENV.fetch('IMPACT_CARD_ID', nil))

    if impact_card.nil?
      puts "Impact card not found: #{ENV.fetch('IMPACT_CARD_ID', nil)}"
      exit(1)
    end

    new_name = ENV.fetch('NEW_NAME', nil)
    target_account = Account.find_by(id: ENV.fetch('TARGET_ACCOUNT_ID', nil))

    ImpactCards::DeepCopy.call(impact_card:, new_name:, target_account:)

    puts 'Deep copying impact card...done'
  end

  desc 'Deep copy merge cards'
  task deep_merge: :environment do
    puts 'Deep merging impact cards...'

    if ENV['IMPACT_CARD_ID'].nil? || ENV['OTHER_IMPACT_CARD_ID'].nil? # rubocop:disable Style/MissingElse
      puts 'IMPACT_CARD_ID and OTHER_IMPACT_CARD_ID are required'
      puts 'Usage: rake impact_cards:deep_copy IMPACT_CARD_ID=1 OTHER_IMPACT_CARD_ID=2'
      exit(1)
    end

    impact_card = Scorecard.find(ENV.fetch('IMPACT_CARD_ID', nil))

    if impact_card.nil? # rubocop:disable Style/MissingElse
      puts "Impact card not found: #{ENV.fetch('IMPACT_CARD_ID', nil)}"
      exit(1)
    end

    other_impact_card = Scorecard.find(ENV.fetch('OTHER_IMPACT_CARD_ID', nil))

    if other_impact_card.nil? # rubocop:disable Style/MissingElse
      puts "Other impact card not found: #{ENV.fetch('OTHER_IMPACT_CARD_ID', nil)}"
      exit(1)
    end

    ImpactCards::DeepMerge.call(impact_card:, other_impact_card:)

    puts 'Deep merging impact cards...done'
  end
end
