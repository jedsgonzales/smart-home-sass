require 'rails_helper'
require 'automation/api/smart_g4'
require 'automation/api/smart_g4/message'
require 'automation/api/smart_g4/protocol_1_4'

RSpec.describe Automation::Api::SmartG4::Protocol_1_4 do
  before(:all) do
    @device_gateway = create(:control_gateway)

    @device_profile = build(:smart_g4_device_profile)
    @control_device = build(:control_device)

    @sbus_for_sub0x1_dev0x44 = [0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00, 0x1D, 0xA3]
    @sbus_from_sub0x1_dev0x44 = [0xAA, 0xAA,
      0x10, # length
      0x01, 0x44, # origin subnet, origin device id
      0xFF, 0xFE, # origin device type
      0x00, 0x32, # op code
      0x01, 0xFF, # dest subnet, dest device id
      0x01, 0xF8, 0x46, 0x02, 0x01, 0x00, 0x00, # content
      0xAF, 0x64 ] # crc
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
        if ch_node.control_channel == 1
          expect(ch_node.node_status_power).to eql(0x46)
        end
      end
    end

  end
end
