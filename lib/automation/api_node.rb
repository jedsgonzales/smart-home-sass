require 'automation/nodes/hvac'
require 'automation/nodes/switch'
require 'automation/nodes/temp_sensor'
require 'automation/nodes/var_volt_control'
require 'automation/nodes/vav'

module Automation
  module ApiNode
    LIST = {
      'Default' => Automation::Nodes::Switch,
      'HVAC' => Automation::Nodes::Hvac,
      'Switch' => Automation::Nodes::Switch,
      'Relay' => Automation::Nodes::Switch,
      'Dimmer' => Automation::Nodes::VarVoltControl,
      'Variable Power Control' => Automation::Nodes::VarVoltControl,
      'Temperature Sensor' => Automation::Nodes::TempSensor,
      'Variable Air Volume' => Automation::Nodes::Vav
    }.with_indifferent_access
  end
end
