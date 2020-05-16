require 'rails_helper'
require 'automation/api/smart_g4'
require 'automation/api/smart_g4/message'
require 'automation/api/smart_g4/protocol_1_4'

RSpec.describe Automation::Api::SmartG4::Protocol_1_4 do
  before(:all) do
    @device_gateway = create(:control_gateway)

    @device_profile = build(:smart_g4_device_profile)
    @control_device = build(:control_device)
  end


  context 'Smart G4 integration with control devices' do
    it 'can build a device profile with api' do
      @device_profile.model_api = 'Smart G4 v1.4'
      @device_profile.model_code = "TEST_PROFILE"

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 1 relay',
          node_type: 'Relay',
          control_channel: 1,
          control_device_profile: @device_profile,
          user_id: 0
        }
      )

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 2 dimmer',
          node_type: 'Dimmer',
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

      @control_device.save if is_valid
    end

  end
end
