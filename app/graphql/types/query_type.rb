module Types
  class QueryType < Types::BaseObject
    field :users, resolver: Types::Queries::Users, description: "Lists all users."
    field :locations, resolver: Types::Queries::Locations, description: "Lists all locations."
  end
end
