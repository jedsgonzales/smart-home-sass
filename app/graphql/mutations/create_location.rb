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

      location = Location.find_by(id: parent_location)
      organization = organization_id.present? ? Organization.includes(user_roles: [:user]).find_by(id: organization_id ) : nil

      raise GraphQL::ExecutionError.new('location not found', extensions: { code: 'LOCATION_ERROR' }) if location.nil?
      raise GraphQL::ExecutionError.new('organization not found', extensions: { code: 'ORGANIZATION_ERROR' }) if organization_id.present? && organization.nil?

      # raise error if parent location organization does not match with given organization
      if organization.present? && location.present? && (location.organization.nil? || location.organization_id != organization_id)
        raise GraphQL::ExecutionError.new('location - organization mix up', extensions: { code: 'LOCATION_ORG_ERROR' })
      end

      # bring up user_role, if present
      user_role = organization.present? ? organization.user_roles.where( user_id: context[:current_user].id ).take : nil

      if context[:current_user].can_create_other_locations? || # absolute right
        organization.nil? && ( location.nil? || location.user_id == context[:current_user].id ) || # just creating a location under his account
        ( organization.present? &&  (
          organization.created_by == context[:current_user].id # is the owner of organization
          user_role.present? && user_role.can_create_organization_locations? # has rights to create location in organization
        ))

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
