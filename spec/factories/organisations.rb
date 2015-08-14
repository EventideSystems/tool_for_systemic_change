FactoryGirl.define do
  factory :organisation do
    name { FFaker::Company.name }

    factory :administrating_organisation,  class: AdministratingOrganisation do

    end
  end

end
