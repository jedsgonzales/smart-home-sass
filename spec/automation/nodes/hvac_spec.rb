require 'rails_helper'
require 'automation/nodes/hvac'

RSpec.describe Automation::Nodes::Hvac do
  describe 'instance methods creation' do
    sw = ControlNode.new.send(:extend, Automation::Nodes::Hvac)

    it 'will contain switch info parameters as reader methods' do
      Automation::Nodes::Hvac::INFO_ATTRS.each do |info_attr|
        expect( sw.respond_to?("node_info_#{info_attr}".to_sym ) ).to be true
      end
    end

    it 'will contain switch info parameters as writer methods' do
      Automation::Nodes::Hvac::INFO_ATTRS.each do |info_attr|
        expect( sw.respond_to?("node_info_#{info_attr}=".to_sym ) ).to be true
      end
    end

    it 'will contain switch info statuses as reader methods' do
      Automation::Nodes::Hvac::STAT_ATTRS.each do |status_attr, v|
        expect( sw.respond_to?("node_status_#{status_attr}".to_sym ) ).to be true
      end
    end

    it 'will contain switch info statuses as writer methods' do
      Automation::Nodes::Hvac::STAT_ATTRS.each do |status_attr, v|
        expect( sw.respond_to?("node_status_#{status_attr}=".to_sym ) ).to be true
      end
    end

    it 'has node_status_ref assigned properly' do
      expect( sw.node_status_ref ).to eql(Automation::Nodes::Hvac::STAT_ATTRS)
    end

  end
end
