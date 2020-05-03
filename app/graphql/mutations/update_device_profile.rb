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

      device_profile = ControlDeviceProfile.includes(:control_node_profiles).find_by(id: profile.id)

      raise_error('control device profile not found', 'CONTROL_DEVICE_PROFILE_ERROR') if device_profile.nil?

      if context[:current_user].can_update_everything_here? || # absolute right
        device_profile.user_id == context[:current_user].id) # device_profile owner

        device_profile.update_attributes(
          name: profile.name,
          description: profile.description,
          model_code: profile.model_code
        )

        ActiveRecord::Base.transaction do
          # update nodes by ID or by control channel

          # nullify all nodes for parent
          delete_list = []
          device_profile.control_node_profiles.each do |existing_cnp|
            delete_list << existing_cnp.id
          end

          profile.node_profiles.each do |node_profile|
            cnp = device_profile.control_node_profiles.exists?(node_profile.id) ? device_profile.control_node_profiles.find(id: node_prodile.id) : device_profile.control_node_profiles.where(control_channel: node_profile.control_channel).take
            cnp = cnp.nil? ? device_profile.control_node_profiles.build : cnp

            cnp.description: node_profile.description,
            cnp.control_channel: node_profile.control_channel,
            cnp.node_type: node_profile.node_type,
            cnp.control_device: device_profile

            delete_list.remove(cnp.id) if cnp.id.present?
          end

          # delete remaining - not updated items
          delete_list.each do |delete_node_id|
            existing_cnp.delete(ControlNodeProfile.find(delete_node_id))
          end

          device_profile.save
        end

        {
          profile: device_profile,
          errors: device_profile.errors.full_messages.collect { |msg| msg },
          node_errors: device_profile.control_node_profiles.collect { |cnp| cnp.errors.full_messages.collect { |msg| "Node Profile: #{msg}" } }
        }

      else
        deny_access
      end

    end
  end
end
