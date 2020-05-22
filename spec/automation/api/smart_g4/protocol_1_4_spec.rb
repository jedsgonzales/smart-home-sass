require 'rails_helper'
require 'automation/constants'
require 'automation/api/smart_g4'
require 'automation/api/smart_g4/message'
require 'automation/api/smart_g4/protocol_1_4'
require 'automation/nodes/switch'
require 'automation/nodes/var_volt_control'

RSpec.describe Automation::Api::SmartG4::Protocol_1_4 do
  before(:all) do
    @constants = Automation::Constants

    @device_gateway = create(:control_gateway)

    @device_profile = build(:smart_g4_device_profile)
    @control_device = build(:control_device)

    @sbus_for_sub0x1_dev0x44 = [0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00, 0x1D, 0xA3]
    @sbus_from_sub0x1_dev0x44 = [0xAA, 0xAA,
      0x12, # length
      0x01, 0x44, # origin subnet, origin device id
      0xFF, 0xFE, # origin device type
      0x00, 0x32, # op code
      0x01, 0xFF, # dest subnet, dest device id
      0x01, 0xF8, 0x46, 0x02, 0x01, 0x00, 0x00, # content
      0xAF, 0x64 ] # crc

    @relay_resp_channel_status = [0xAA, 0xAA,
      0x0E, # length
      0x01, 0x44, # origin subnet, origin device id
      0xFF, 0xFE, # origin device type
      0x00, 0x34, # op code
      0x01, 0xFF, # dest subnet, dest device id
      0x02, 0x32, 0x64, # content
      0xA1, 0x3B ] # crc

    @relay_periodic_status = [0xAA, 0xAA,
        0x12, # length
        0x01, 0x44, # origin subnet, origin device id
        0xFF, 0xFE, # origin device type
        0xEF, 0xFF, # op code
        0xFF, 0xFF, # dest subnet, dest device id
        0x01, 0x00, # zones content
        0x02, 0x02, 0x00, 0x00, 0x00, # channels content
        0xB8, 0x36 ] # crc
  end


  context 'Smart G4 integration with control devices' do
    it 'can build a device profile with api' do
      @device_profile.model_api = 'Smart G4 v1.4'
      @device_profile.model_code = "TEST_PROFILE"

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 1 dimmer',
          node_type: 'Dimmer',
          control_channel: 1,
          control_device_profile: @device_profile,
          user_id: 0
        }
      )

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 2 relay',
          node_type: 'Relay',
          control_channel: 2,
          control_device_profile: @device_profile,
          user_id: 0
        }
      )

      is_valid = @device_profile.valid?

      expect(is_valid).to be true

      @device_profile.save if is_valid
    end

    it 'can create control device based on device profile imprint' do
      @control_device.control_device_profile = @device_profile
      @control_device.control_gateway = @device_gateway
      @control_device.api_model_params = { subnet_id: 1, device_id: 0x44, device_type: 0xFFFE }

      @device_profile.control_node_profiles.each do |node_profile|
        @control_device.control_nodes.build(
          control_device: @control_device,
          control_node_profile: node_profile,
          control_channel: node_profile.control_channel,
          details: "#{@device_profile.model_code} / #{node_profile.description}"
        )
      end

      is_valid = @control_device.valid?

      puts "\nValidation Error: #{@control_device.errors.inspect}" unless is_valid

      expect(is_valid).to be true
    end

    it 'saves properly when valid' do
      expect(@control_device.save).to be true
    end

    it 'will respond with api methods' do
      expect(@control_device.respond_to?(:receive)).to be true
    end

    it 'will only process messages intended for itself' do
      @control_device.save
      result = Automation::Api::SmartG4::Message.consume(@sbus_from_sub0x1_dev0x44)
      expect(@control_device.receive(result[:message])).to be true
    end

    it 'sets relay channel 1 status to 0x46' do
      @control_device.control_nodes.each do |ch_node|
        # skip nodes that are not relays
        next unless ch_node.is_a?(Automation::Nodes::Switch) || ch_node.is_a?(Automation::Nodes::VarVoltControl)

        if ch_node.control_channel == 1
          expect(ch_node.node_status_power).to eql(0x46)
        end
      end
    end

    it 'updates all channels on relay op_code 0x0034' do
      result = Automation::Api::SmartG4::Message.consume(@relay_resp_channel_status)

      expect(result[:message]).not_to be nil

      @control_device.receive(result[:message])
      @control_device.control_nodes.each do |ch_node|
        # skip nodes that are not relays
        next unless ch_node.is_a?(Automation::Nodes::Switch) || ch_node.is_a?(Automation::Nodes::VarVoltControl)

        if ch_node.control_channel == 1
          expect(ch_node.node_status_power).to eql(0x32)
        elsif ch_node.control_channel == 2
          expect(ch_node.node_status_power).to eql(0x64)
        end
      end
    end

    it 'updates all channels on relay op_code 0xEFFF' do
      result = Automation::Api::SmartG4::Message.consume(@relay_periodic_status)

      expect(result[:message]).not_to be nil

      @control_device.receive(result[:message])
      @control_device.control_nodes.each do |ch_node|
        # skip nodes that are not relays
        next unless ch_node.is_a?(Automation::Nodes::Switch) || ch_node.is_a?(Automation::Nodes::VarVoltControl)

        if ch_node.control_channel == 1
          expect(ch_node.node_status_power).to eql(0)
        elsif ch_node.control_channel == 2
          expect(ch_node.node_status_power).to eql(0x64)
        end
      end
    end

    it 'can add hvac node profile to control profile' do
      hvac_channel = @device_profile.control_node_profiles.build(
        {
          description: 'channel 1 AC',
          node_type: 'HVAC',
          control_channel: 1,
          control_device_profile: @device_profile,
          user_id: 0
        }
      )

      hvac_valid = hvac_channel.valid?

      puts "\nValidation Error: #{hvac_channel.errors.inspect}" unless hvac_valid

      is_valid = @device_profile.valid?

      puts "\nValidation Error: #{@device_profile.errors.inspect}" unless is_valid

      expect(is_valid).to be true

      @device_profile.save if is_valid
    end

    it 'can parse HVAC op code 0x193B properly' do
      hvac_ctrl_resp = [0xAA, 0xAA,
          24, # length
          0x01, 0x44, # origin subnet, origin device id
          0xFF, 0xFE, # origin device type
          0x19, 0x3B, # op code
          0xFF, 0xFF, # dest subnet, dest device id
          0x01, 0x00, 25, 20, 30, 25, 00, 0x00, 0x01, 0x00, 0x00, 20, 00, # content
          55, 236 ] # crc

      result = Automation::Api::SmartG4::Message.consume(hvac_ctrl_resp)

      expect(result[:message]).not_to be nil

      @control_device.receive(result[:message])
      @control_device.control_nodes.each do |ch_node|
        # skip nodes that are not hvac
        next unless ch_node.is_a?(Automation::Nodes::Hvac)

        if ch_node.control_channel == 1
          expect(ch_node.node_status_ac_status_str).to eql(@constants::POWER[1])
          expect(ch_node.node_status_temp_unit_str).to eql(@constants::TEMP_UNIT[0])
          expect(ch_node.node_status_curr_temp).to eql(25)
          expect(ch_node.node_status_cool_set_point).to eql(20)
          expect(ch_node.node_status_heat_set_point).to eql(30)
          expect(ch_node.node_status_auto_set_point).to eql(25)
          expect(ch_node.node_status_mode_str).to eql(@constants::TEMP_MODE[0])
          expect(ch_node.node_status_fan_str).to eql(@constants::FAN_MODE[0])
        end
      end
    end

  end
end
