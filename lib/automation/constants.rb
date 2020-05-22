module Automation
  module Constants
    BYTE = (0..255).to_a
    ZERO_TO_100 = (0..100).to_a
    ZERO_TO_10 = (0..10).to_a

    POWER = {
      0 => 'off',
      1 => 'on',
      100 => 'on'
    }

    TEMP_MODE = {
      0 => 'cool',
      1 => 'heat',
      2 => 'fan',
      4 => 'dry'
    }

    FAN_MODE = {
      0 => 'auto',
      1 => 'high',
      2 => 'medium',
      4 => 'low'
    }

    TEMP_UNIT = {
      0 => 'celcius',
      1 => 'fahrenheit'
    }
  end
end
