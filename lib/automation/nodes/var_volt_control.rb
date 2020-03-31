module Automation
  module Nodes
    module VarVoltControl
      include Automation::Nodes::Node

      INFO_ATTRS = %w(id)
      STAT_ATTRS = { percentage: 0..100 }

      def self.included(base)
        create_info_accessors(Automation::Nodes::VarVoltControl::INFO_ATTRS)
        create_stat_accessors(Automation::Nodes::VarVoltControl::STAT_ATTRS)

        load_node_data( (Automation::Nodes::VarVoltControl::ATTRS + Automation::Nodes::VarVoltControl::STAT_ATTRS.keys).uniq )
      end

    end
  end
end
