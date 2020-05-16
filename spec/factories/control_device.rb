require 'faker'
require 'automation/api/smart_g4'

FactoryBot.define do
  factory :control_device do
    name { 'Control Device' }
    details { 'Fake control device' }
  end
end
