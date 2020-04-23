require 'rails_helper'
require 'automation/nodes/switch'

RSpec.describe Automation::Nodes::Switch do
  describe 'class inclusion' do
    sw = ControlNode.new.send(:extend, Automation::Nodes::Switch)

    it 'will contain switch info parameters as reader methods' do
      Automation::Nodes::Switch::INFO_ATTRS.each do |info_attr|
        expect( sw.respond_to?("node_info_#{info_attr}".to_sym ) ).to be true
      end
    end

    it 'will contain switch info parameters as writer methods' do
      Automation::Nodes::Switch::INFO_ATTRS.each do |info_attr|
        expect( sw.respond_to?("node_info_#{info_attr}=".to_sym ) ).to be true
      end
    end

    it 'will contain switch info statuses as reader methods' do
      Automation::Nodes::Switch::STAT_ATTRS.each do |status_attr, v|
        expect( sw.respond_to?("node_status_#{status_attr}".to_sym ) ).to be true
      end
    end

    it 'will contain switch info statuses as writer methods' do
      Automation::Nodes::Switch::STAT_ATTRS.each do |status_attr, v|
        expect( sw.respond_to?("node_status_#{status_attr}=".to_sym ) ).to be true
      end
    end

    it 'can accept relay value of 0 and 100 only' do
      val = Automation::Nodes::Switch::STAT_ATTRS[:power].sample

      sw.node_status_power = val

      expect( sw.node_status_power ).to eql(val)
    end

  end
end
