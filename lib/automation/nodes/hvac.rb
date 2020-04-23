require 'automation/nodes/node'
require 'automation/constants'

module Automation
  module Nodes
    module Hvac
      include Automation::Nodes::Node
      extend  Automation::Nodes::NodeClassMethods

      INFO_ATTRS = %w(id).freeze
      STAT_ATTRS = {
        temp_unit: Automation::Constants::TEMP_UNIT.values,
        ac_status: Automation::Constants::POWER.values,
        curr_temp: Automation::Constants::BYTE,
        cool_set_point: Automation::Constants::BYTE,
        heat_set_point: Automation::Constants::BYTE,
        auto_set_point: Automation::Constants::BYTE,
        mode: Automation::Constants::TEMP_MODE.values,
        fan:  Automation::Constants::FAN_MODE.values,
      }.freeze

      def self.extended(base)
        create_accessors(base, INFO_ATTRS, STAT_ATTRS)
        create_callbacks(base, 'Automation::Nodes::Hvac::INFO_ATTRS', 'Automation::Nodes::Hvac::STAT_ATTRS')
      end

    end
  end
end
