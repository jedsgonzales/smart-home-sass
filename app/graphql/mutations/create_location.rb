module Mutations
  class CreateLocation < BaseMutation
    # arguments passed to the `resolved` method
    argument :location_name, String, required: true
    argument :location_type, Integer, required: true
    argument :description, String, required: true
    argument :parent_location, Integer, required: true
    argument :organization_id, ID, required: false

    # return type from the mutation
    field :location, Types::Objects::LocationType, null: true
    field :errors, [String], null: true

    def resolve(location_name: nil, location_type: nil, description: nil, parent_location: nil, organization_id: nil)
      auth_checkpoint

      raise GraphQL::ExecutionError.new('object not found', extensions: { code: 'ORGANIZATION_ERROR' })

      if ( organization_id.present? && context[:current_user].can_create_other_locations? ) # absolute right
        # check organization membership role
        location = Location.create!(
          location_name: location_name,
          location_type: location_type,
          description: description,
          parent_location: parent_location,
          organization_id: organization_id,
          user: context[:current_user]
        )

        {
          location: location,
          errors: location.errors.full_messages.collect { |msg| msg }
        }
      else
        deny_access
      end
    end
  end
end
