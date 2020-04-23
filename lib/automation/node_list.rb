module Automation
  module NodeList
    MAP = {
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
