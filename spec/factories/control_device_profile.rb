require 'faker'
require 'automation/api/smart_g4'

FactoryBot.define do
  factory :control_device_profile do
    name { 'Control Profile' }
    model_code { 'CD1' }
    description { 'Fake control device profile' }

    factory :smart_g4_device_profile do
      name { 'Smart G4 Device' }
      model_code { 'RELAY_ONLY_DEV' }
      model_api { 'Smart G4 v1.4' }
    end
  end
end
