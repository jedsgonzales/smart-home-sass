module Mutations
  class CreateLocation < BaseMutation
    # arguments passed to the `resolved` method
    argument :location_name, String, required: true
    argument :location_type, Integer, required: true
    argument :description, String, required: true
    argument :parent_location, Integer, required: true
    argument :organization_id, ID, required: false

    # return type from the mutation
    type Types::Objects::LocationType

    def resolve(location_name: nil, location_type: nil, description: nil, parent_location: nil, organization_id: nil)

      raise GraphQL::ExecutionError, "ORGANIZATION_ERROR" unless organization_id.present? && Organization.exists?(organization_id)

      if ( organization_id.present? && context[:current_user].can_create_other_locations? ) # absolute right
        # check organization membership role
        Location.create!(
          location_name: location_name,
          location_type: location_type,
          description: description,
          parent_location: parent_location,
          organization_id: organization_id,
          user: context[:current_user]
        )
      else
        raise GraphQL::ExecutionError, "INSUFFICIENT_PRIVILEDGE"
      end
    end
  end
end
