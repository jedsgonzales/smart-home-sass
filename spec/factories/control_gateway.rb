require 'faker'

FactoryBot.define do
  factory :control_gateway do
    ip_address { Faker::Internet.ip_v4_address }
    description { 'Fake gateway profile' }
    comm_type { 'UDP' }
    port { Faker::Number.number(digits: 4) }
  end
end
