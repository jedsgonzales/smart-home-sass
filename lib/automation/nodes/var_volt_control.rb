require 'automation/nodes/node'
require 'automation/constants'

module Automation
  module Nodes
    module VarVoltControl
      include Automation::Nodes::Node
      extend  Automation::Nodes::NodeClassMethods

      INFO_ATTRS = %w(id).freeze
      STAT_ATTRS = { power: Automation::Constants::ZERO_TO_100 }.freeze

      def self.included(base)
        create_accessors(base, INFO_ATTRS, STAT_ATTRS)
        create_callbacks(base, 'Automation::Nodes::VarVoltControl::INFO_ATTRS', 'Automation::Nodes::VarVoltControl::STAT_ATTRS')
      end

    end
  end
end
