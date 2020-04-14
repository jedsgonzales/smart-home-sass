module Mutations
  class DeleteLocation < BaseMutation
    # TODO: define return fields
    field :location, Types::Objects::LocationType, null: false
    field :result, Boolean, null: true

    argument :id, ID, required: true
    argument :organization_id, ID, required: false

    def resolve(id:, organization_id: nil)

      raise GraphQL::ExecutionError, "LOCATION_ERROR" unless id.present? && Location.exists?(id)
      raise GraphQL::ExecutionError, "ORGANIZATION_ERROR" unless organization_id.present? && Organization.exists?(organization_id)

      if ( context[:current_user].can_delete_other_locations? ) # absolute right
        location = Location.destroy(id)

        {
          location: location,
          result: location.errors.blank?
        }
      else
        raise GraphQL::ExecutionError, "INSUFFICIENT_PRIVILEDGE"
      end

    end
  end
end
