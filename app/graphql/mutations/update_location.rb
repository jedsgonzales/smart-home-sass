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
      auth_checkpoint

      location = Location.includes(:organization => [ {user_roles: :user} ]).find_by(id: id)

      raise GraphQL::ExecutionError.new('location not found', extensions: { code: 'LOCATION_ERROR' }) if location.nil?
      raise GraphQL::ExecutionError.new('organization not found', extensions: { code: 'ORGANIZATION_ERROR' }) if organization_id.present? && !Organization.exists?(organization_id)

      # bring up user_role, if present
      user_role = location.organization.user_roles.where( user_id: context[:current_user].id ).take

      if context[:current_user].can_update_other_locations? || # absolute right
        (location.user_id == context[:current_user].id && location.organization.nil?)  || # sole owner
        (  location.organization.present? && # location belongs to organization
           ( location.organization.user_id == context[:current_user].id ) || # organization is owned by current_user
           ( user_role.present? && user_role.can_update_organization_locations? ) # has rights to update locations under organization
        )

        location.update_attributes(
          location_name: location_name,
          location_type: location_type,
          parent_location: parent_location,
          description: description,
          organization_id: organization_id)

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
