require 'faker'

FactoryBot.define do
  factory :control_node_profile do
    control_channel { 1 }
    node_type { 'Default' }
    description { 'Fake relay node profile' }

    factory :smart_g4_relay_node do
      node_type { 'Relay' }
    end
  end
end
