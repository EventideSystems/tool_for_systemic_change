FactoryGirl.define do
  factory :organisation do
    name { FFaker::Company.name }
    description { FFaker::Lorem.words.join(' ') }

    factory :administrating_organisation,  class: AdministratingOrganisation do

    end
  end

end
