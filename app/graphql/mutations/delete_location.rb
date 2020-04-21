module Mutations
  class DeleteLocation < BaseMutation
    # TODO: define return fields
    field :location, Types::Objects::LocationType, null: false
    field :result, Boolean, null: true

    argument :id, ID, required: true
    argument :organization_id, ID, required: false

    def resolve(id:)
      auth_checkpoint

      location = Location.includes(:organization => [ {user_roles: :user} ]).find_by(id: id)

      raise GraphQL::ExecutionError.new('location not found', extensions: { code: 'LOCATION_ERROR' }) if location.nil?

      # bring up user_role, if present
      user_role = location.organization.user_roles.where( user_id: context[:current_user].id ).take

      if context[:current_user].can_delete_other_locations? || # absolute right
         (location.user_id == context[:current_user].id && location.organization.nil?)  || # location owner
         (  location.organization.present? && # location belongs to organization
            ( location.organization.user_id == context[:current_user].id ) || # organization is owned by current_user
            ( user_role.present? && user_role.can_delete_organization_locations? ) # has rights to delete locations under organization
         )

        location.destroy

        {
          location: location,
          result: location.errors.blank?
        }
      else
        deny_access
      end

    end
  end
end
