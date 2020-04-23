require 'automation/nodes/node'
require 'automation/constants'

module Automation
  module Nodes
    module TempSensor
      include Automation::Nodes::Node
      extend  Automation::Nodes::NodeClassMethods

      INFO_ATTRS = %w(id).freeze
      STAT_ATTRS = {
        temp_unit: Automation::Constants::TEMP_UNIT.values,
        curr_temp: Automation::Constants::BYTE,

      }.freeze

      def self.extended(base)
        create_accessors(base, INFO_ATTRS, STAT_ATTRS)
        create_callbacks(base, 'Automation::Nodes::TempSensor::INFO_ATTRS', 'Automation::Nodes::TempSensor::STAT_ATTRS')
      end

    end
  end
end
