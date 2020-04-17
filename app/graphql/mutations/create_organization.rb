module Mutations
  class CreateOrganization < BaseMutation
    # arguments passed to the `resolved` method
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
      name: nil,  short_name: '', details: '',
      site_url: '', address: '', contact_details: '',
      private_info: false, public_list: false)

      auth_checkpoint

      # check organization membership role
      organization = Organization.create!(
        name: name,  short_name: short_name, details: details,
        site_url: site_url, address: address, contact_details: contact_details,
        private_info: private_info, public_list: public_list,
        user: context[:current_user]
      )

      {
        organization: organization,
        errors: organization.errors.full_messages.collect { |msg| msg }
      }
    end
  end
end
