module Types
  class MutationType < Types::BaseObject
    field :auth_user, mutation: Mutations::AuthUser

    field :delete_location, mutation: Mutations::DeleteLocation
    field :update_location, mutation: Mutations::UpdateLocation
    field :create_location, mutation: Mutations::CreateLocation

    field :create_organization, mutation: Mutations::CreateOrganization
    field :update_organization, mutation: Mutations::UpdateOrganization
    field :delete_organization, mutation: Mutations::DestroyOrganization
  end
end
