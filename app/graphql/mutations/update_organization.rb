module Mutations
  class UpdateOrganization < BaseMutation
    # arguments passed to the `resolved` method
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :short_name, String, required: false
    argument :details, String, required: false
    argument :site_url, String, required: false
    argument :address, String, required: false
    argument :contact_details, String, required: false
    argument :private_info, Boolean, required: false
    argument :public_list, Boolean, required: false

    # return type from the mutation
    field :organization, Types::Objects::OrganizationType, null: true
    field :errors, [String], null: true

    def resolve(
      id:, name: nil,  short_name: '', details: '',
      site_url: '', address: '', contact_details: '',
      private_info: false, public_list: false)

      auth_checkpoint

      organization = Organization.includes(user_roles => [:users]).find_by(id: id)

      raise GraphQL::ExecutionError.new('organization not found', extensions: { code: 'ORGANIZATION_ERROR' }) if organization.nil?

      # bring up user_role, if present
      user_role = organization.user_roles.where( user_id: context[:current_user].id ).take

      if context[:current_user].can_update_other_organizations? || # absolute rights
        organization.created_by == context[:current_user].id || # owner of the organization
        ( user_role.present? && user_role.can_update_organization_instance? ) # user has rights to update the organization instance

        organization = Organization.update_attributes(
          name: name,  short_name: short_name, details: details,
          site_url: site_url, address: address, contact_details: contact_details,
          private_info: private_info, public_list: public_list,
          user: context[:current_user]
        )

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
