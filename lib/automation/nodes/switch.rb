require 'automation/nodes/node'
require 'automation/constants'

module Automation
  module Nodes
    module Switch
      include Automation::Nodes::Node
      extend  Automation::Nodes::NodeClassMethods

      INFO_ATTRS = %w(id).freeze
      STAT_ATTRS = { power: Automation::Constants::POWER.keys }.freeze
      STAT_NAMES = { power: Automation::Constants::POWER }.freeze

      def self.extended(base)
        create_accessors(base, INFO_ATTRS, STAT_ATTRS)
        create_callbacks(base, 'Automation::Nodes::Switch::INFO_ATTRS', 'Automation::Nodes::Switch::STAT_ATTRS', 'Automation::Nodes::Switch::STAT_NAMES')
      end

    end
  end
end
