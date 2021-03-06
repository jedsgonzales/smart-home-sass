require 'automation/nodes/node'
require 'automation/constants'

module Automation
  module Nodes
    module Vav
      include Automation::Nodes::Node
      extend  Automation::Nodes::NodeClassMethods

      INFO_ATTRS = %w(id).freeze
      STAT_ATTRS = { power: Automation::Constants::ZERO_TO_10 }.freeze

      def self.extended(base)
        create_accessors(base, INFO_ATTRS, STAT_ATTRS)
        create_callbacks(base, 'Automation::Nodes::Vav::INFO_ATTRS', 'Automation::Nodes::Vav::STAT_ATTRS')
      end

    end
  end
end
