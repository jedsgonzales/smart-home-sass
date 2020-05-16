require "rails_helper"
require 'automation/api'
require 'automation/api_node'

RSpec.describe ControlDeviceProfile, :type => :model do
  before(:all) do
    @device_profile = build(:control_device_profile)
  end

  context 'Standard Automation API Integrations' do
    it 'can build a device profile with correct api and node type' do
      @device_profile.model_api = Automation::Api::LIST.keys.first
      @device_profile.model_code = "TEST_PROFILE"

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 1 node',
          node_type: Automation::ApiNode::LIST.keys.first,
          control_channel: 1,
          control_device_profile: @device_profile,
          user_id: 0
        }
      )

      expect(@device_profile.valid?).to be true
    end

    it 'cannot build a device profile with incorrect node type' do
      @device_profile.model_api = Automation::Api::LIST.keys.first
      @device_profile.model_code = "TEST_PROFILE"

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 1 node',
          node_type: "#{Automation::ApiNode::LIST.keys.first} - BUMMER",
          control_device_profile: @device_profile,
          control_channel: 1,
          user_id: 0
        }
      )

      expect(@device_profile.valid?).to be false
    end

    it 'cannot build a device profile with invalid api' do
      @device_profile.model_api = "#{Automation::Api::LIST.keys.first} - BUMMER"
      @device_profile.model_code = "TEST_PROFILE"

      @device_profile.control_node_profiles.build(
        {
          description: 'channel 1 node',
          node_type: Automation::ApiNode::LIST.keys.first,
          control_device_profile: @device_profile,
          control_channel: 1,
          user_id: 0
        }
      )

      expect(@device_profile.valid?).to be false
    end
  end

end
