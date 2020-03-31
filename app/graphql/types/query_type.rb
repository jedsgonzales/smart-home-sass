module Types
  class QueryType < Types::BaseObject
    field :list_users, [UserType], null: false, description: "Lists all users."

    field :list_locations, [LocationType], null: false, description: "List all locations."

    def list_users
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "CREDS_INVALID"
      end

      User.all
    end

    def list_locations
    	Location.all
    end
  end
end
