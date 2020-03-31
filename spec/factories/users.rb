require 'faker'

FactoryBot.define do
  sequence :email do |n|
    "did-user#{n}@v-ecom.com"
  end
  
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { generate :email }
    password { 'admin123' }

    status { User.statuses[:active] }
  end
end
