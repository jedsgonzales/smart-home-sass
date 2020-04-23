module Types
  class QueryType < Types::BaseObject
    field :users, resolver: Types::Queries::Users, description: "Lists all users."
    field :locations, resolver: Types::Queries::Locations, description: "Lists all locations."
    field :node_types, resolver: Types::Queries::NodeClasses, description: "Lists all possible node ends controls."
  end
end
