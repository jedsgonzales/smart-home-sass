require 'faker'

FactoryBot.define do
  factory :control_device_profile do
    name { 'Control Profile' }
    model_code { 'CD1' }
    description { 'Fake control device profile' }

    factory :smart_g4_device do
      name { 'Smart G4 Device' }
      model_code { 'RELAY_ONLY_DEV' }
      model_api { 'SMART G4 1.2' }
    end
  end
end
