module Automation
  module Constants
    BYTE = (0..255).to_a
    ZERO_TO_100 = (0..100).to_a
    ZERO_TO_10 = (0..10).to_a

    POWER = {
      off: 0,
      on: 1
    }

    TEMP_MODE = {
      cool: 1,
      auto: 2,
      heat: 3
    }

    FAN_MODE = {
      auto: 0,
      low: 1,
      medium: 2,
      high: 3
    }

    TEMP_UNIT = {
      fahrenheit: 0,
      celsius: 1
    }
  end
end
