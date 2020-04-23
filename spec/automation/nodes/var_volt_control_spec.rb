require 'rails_helper'
require 'automation/nodes/var_volt_control'

RSpec.describe Automation::Nodes::VarVoltControl do
  describe 'instance methods creation' do
    sw = ControlNode.new.send(:extend, Automation::Nodes::VarVoltControl)

    it 'will contain switch info parameters as reader methods' do
      Automation::Nodes::VarVoltControl::INFO_ATTRS.each do |info_attr|
        expect( sw.respond_to?("node_info_#{info_attr}".to_sym ) ).to be true
      end
    end

    it 'will contain switch info parameters as writer methods' do
      Automation::Nodes::VarVoltControl::INFO_ATTRS.each do |info_attr|
        expect( sw.respond_to?("node_info_#{info_attr}=".to_sym ) ).to be true
      end
    end

    it 'will contain switch info statuses as reader methods' do
      Automation::Nodes::VarVoltControl::STAT_ATTRS.each do |status_attr, v|
        expect( sw.respond_to?("node_status_#{status_attr}".to_sym ) ).to be true
      end
    end

    it 'will contain switch info statuses as writer methods' do
      Automation::Nodes::VarVoltControl::STAT_ATTRS.each do |status_attr, v|
        expect( sw.respond_to?("node_status_#{status_attr}=".to_sym ) ).to be true
      end
    end

    it 'can accept relay value from 0 to 100' do
      val = rand(101)

      sw.node_status_power = val

      expect( sw.node_status_power ).to eql(val)
    end
  end
end
