module Mutations
  class DestroyDeviceProfile < BaseMutation
    # arguments passed to the `resolved` method
    argument :id, ID, required: true

    # return type from the mutation
    field :profile, Types::Objects::DeviceProfileType, null: true
    field :errors, [String], null: true

    def resolve(id:)
      auth_checkpoint

      device_profile = ControlDeviceProfile.includes(:control_node_profiles).find_by(id: profile.id)

      raise_error('control device profile not found', 'CONTROL_DEVICE_PROFILE_ERROR') if device_profile.nil?

      if context[:current_user].can_delete_everything_here? || # absolute right
        device_profile.user_id == context[:current_user].id) # device_profile owner

        device_profile.destroy

        {
          profile: device_profile,
          errors: device_profile.errors.full_messages.collect { |msg| msg }
        }
      else
        deny_access
      end

    end
  end
end
