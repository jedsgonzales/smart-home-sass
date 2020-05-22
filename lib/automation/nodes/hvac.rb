require 'automation/nodes/node'
require 'automation/constants'

module Automation
  module Nodes
    module Hvac
      include Automation::Nodes::Node
      extend  Automation::Nodes::NodeClassMethods

      INFO_ATTRS = %w(id unit_no).freeze
      STAT_ATTRS = {
        temp_unit: Automation::Constants::TEMP_UNIT.keys,
        ac_status: Automation::Constants::POWER.keys,
        curr_temp: Automation::Constants::BYTE,
        cool_set_point: Automation::Constants::BYTE,
        heat_set_point: Automation::Constants::BYTE,
        auto_set_point: Automation::Constants::BYTE,
        mode: Automation::Constants::TEMP_MODE.keys,
        fan:  Automation::Constants::FAN_MODE.keys,
      }.freeze
      STAT_NAMES = {
        temp_unit: Automation::Constants::TEMP_UNIT,
        ac_status: Automation::Constants::POWER,
        mode: Automation::Constants::TEMP_MODE,
        fan:  Automation::Constants::FAN_MODE,
      }.freeze

      def self.extended(base)
        create_accessors(base, INFO_ATTRS, STAT_ATTRS)
        create_callbacks(base, 'Automation::Nodes::Hvac::INFO_ATTRS', 'Automation::Nodes::Hvac::STAT_ATTRS', 'Automation::Nodes::Hvac::STAT_NAMES')
      end

    end
  end
end
