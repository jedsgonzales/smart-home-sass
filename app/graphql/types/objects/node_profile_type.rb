module Types::Objects
  class NodeProfileType < Types::BaseObject
    field :id, ID, null: false
    field :description, String, null: true
    field :node_type, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
