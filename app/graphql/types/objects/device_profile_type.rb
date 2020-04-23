module Types::Objects
  class DeviceProfileType < Types::BaseObject
    field :id, ID, null: true
    field :name, String, null: false
    field :model_code, String, null: false
    field :description, String, null: true
    field :created_by, Types::Objects::UserType, null: true
    field :node_profiles, [Types::Objects::NodeProfileType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
