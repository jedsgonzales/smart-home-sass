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
    system_role { 0x0 }

    status { User.statuses[:active] }

    factory :admin_user do
      system_role { 0x0fffffffffffffff }
    end

    factory :banned_user do
      status { User.statuses[:suspended] }
    end
  end
end
