module Automation
  module Nodes
    module TempSensor
      include Automation::Nodes::Node

      INFO_ATTRS = %w(id temp_unit)
      STAT_ATTRS = {
        temperature: -200..500 # all temp readings will based on degree farenheit
      }

      def self.included(base)
        create_info_accessors(Automation::Nodes::TempSensor::INFO_ATTRS)
        create_stat_accessors(Automation::Nodes::TempSensor::STAT_ATTRS)

        load_node_data( (Automation::Nodes::TempSensor::ATTRS + Automation::Nodes::TempSensor::STAT_ATTRS.keys).uniq )
      end

    end
  end
end
