module Automation
  module Nodes
    module Switch
      include Automation::Nodes::Node

      INFO_ATTRS = %w(id)
      STAT_ATTRS = { power: 0..1 }

      def self.included(base)
        create_info_accessors(Automation::Nodes::Switch::INFO_ATTRS)
        create_stat_accessors(Automation::Nodes::Switch::STAT_ATTRS)

        load_node_data( (Automation::Nodes::Switch::ATTRS + Automation::Nodes::Switch::STAT_ATTRS.keys).uniq )
      end

    end
  end
end
