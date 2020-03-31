require 'faker'

FactoryBot.define do
  factory :location do
    location_name { Faker::Company.name }
    parent { nil }

    location_type { Location.location_types[:area] }
  end
end
