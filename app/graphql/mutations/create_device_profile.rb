module Mutations
  class CreateDeviceProfile < BaseMutation
    # arguments passed to the `resolved` method
    argument :profile, Types::Objects::DeviceProfileType, required: true

    # return type from the mutation
    field :profile, Types::Objects::DeviceProfileType, null: true
    field :errors, [String], null: true
    field :node_errors, [String], null: true

    def resolve(profile: nil)
      auth_checkpoint

      device_profile = ControlDeviceProfile.new!(
        name: profile.name,
        description: profile.description,
        model_code: profile.model_code,
        user: context[:current_user],
      )

      ActiveRecord::Base.transaction do
        device_profile.control_node_profiles = profile.node_profiles.collect { |node_profile| ControlNodeProfile.new(
          description: node_profile.description,
          control_channel: node_profile.control_channel,
          node_type: node_profile.node_type,
          control_device: device_profile
        )}

        device_profile.save
      end

      {
        profile: device_profile,
        errors: device_profile.errors.full_messages.collect { |msg| msg },
        node_errors: device_profile.control_node_profiles.collect { |cnp| cnp.errors.full_messages.collect { |msg| "Node Profile: #{msg}" } }
      }

    end
  end
end
