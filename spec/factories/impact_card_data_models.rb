# frozen_string_literal: true

FactoryBot.define do
  factory :impact_card_data_model do
    name { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }
  end
end
