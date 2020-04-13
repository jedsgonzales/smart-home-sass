module Types::Objects
  class LocationType < Types::BaseObject
    field :id, ID, null: false
    field :location_name, String, null: false
    field :location_type, Integer, null: false
    field :description, String, null: true
    field :parent_location, Integer, null: false
  end
end
