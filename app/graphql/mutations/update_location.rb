module Mutations
  class UpdateLocation < BaseMutation
    # TODO: define return fields
    # field :post, Types::PostType, null: false
    field :location, Types::Objects::LocationType, null: true
    field :errors, [String], null: true


    # TODO: define arguments
    # argument :name, String, required: true
    argument :id, ID, required: true
    argument :location_name, String, required: true
    argument :location_type, Integer, required: true
    argument :parent_location, ID, required: false
    argument :description, String, required: false
    argument :organization_id, ID, required: false

    # TODO: define resolve method
    def resolve(id: nil, location_name: nil, location_type: nil, description: nil, parent_location: nil, organization_id: nil)

      raise GraphQL::ExecutionError, "LOCATION_ERROR" unless id.present? && Location.exists?(id)
      raise GraphQL::ExecutionError, "ORGANIZATION_ERROR" unless organization_id.present? && Organization.exists?(organization_id)

      if ( organization_id.present? && context[:current_user].can_update_other_locations? ) # absolute right
        # check organization membership role

        location = Location.find(id)
        location.update_attributes(
          location_name: :location_name,
          location_type: :location_type,
          parent_location: :parent_location,
          description: :description,
          organization_id: organization_id)

        {
          location: location,
          result: location.errors.full_messages.collect { |msg| msg }
        }
      else
        raise GraphQL::ExecutionError, "INSUFFICIENT_PRIVILEDGE"
      end

    end
  end
end
