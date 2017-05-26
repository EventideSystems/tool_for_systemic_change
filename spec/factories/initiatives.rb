FactoryGirl.define do
  factory :initiative do
    name { FFaker::Name.name }
    scorecard
  end
end