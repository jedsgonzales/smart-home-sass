module Mutations
  class DestroyOrganization < BaseMutation
    # arguments passed to the `resolved` method
    argument :id, ID, required: true

    # return type from the mutation
    field :organization, Types::Objects::OrganizationType, null: true
    field :errors, [String], null: true

    def resolve(id:)
      auth_checkpoint

      organization = Organization.includes(user_roles => [:users]).find_by(id: id)

      raise GraphQL::ExecutionError.new('organization not found', extensions: { code: 'ORGANIZATION_ERROR' }) if organization.nil?

      # bring up user_role, if present
      user_role = organization.user_roles.where( user_id: context[:current_user].id ).take

      if context[:current_user].can_delete_system_organizations? || # absolute right
        context[:current_user].can_delete_everything_here? || # absolute right
        organization.created_by == context[:current_user].id || # organization owner
        ( user_role.present? && user_role.can_delete_organization_instance? ) # user has rights to delete the organization instance

        organization.destroy

        {
          organization: organization,
          errors: organization.errors.full_messages.collect { |msg| msg }
        }
      else
        deny_access
      end

    end
  end
end
