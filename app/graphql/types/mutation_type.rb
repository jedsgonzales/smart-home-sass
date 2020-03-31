module Types
  class MutationType < Types::BaseObject
    field :delete_location, mutation: Mutations::DeleteLocation
    field :update_location, mutation: Mutations::UpdateLocation
    field :auth_user, mutation: Mutations::AuthUser
    field :create_location, mutation: Mutations::CreateLocation
  end
end
