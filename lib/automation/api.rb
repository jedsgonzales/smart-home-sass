require 'automation/api/smart_g4'

module Automation
  module Api
    LIST = {}.merge(
      SmartG4::PROTOCOLS.transform_keys{ |k| "Smart G4 #{k}" }
    )
  end
end
