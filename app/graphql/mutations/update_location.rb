module Mutations
  class UpdateLocation < BaseMutation
    # TODO: define return fields
    # field :post, Types::PostType, null: false
    field :location, type Types::Objects::LocationType, null: true
    field :errors, String, null: false


    # TODO: define arguments
    # argument :name, String, required: true
    argument :id, ID, required: true
    argument :location_name, String, required: true
    argument :location_type, Integer, required: true
    argument :parent_location, Integer, required: true
    argument :description, String, required: false

    # TODO: define resolve method
    def resolve(**args)
      # { post: ... }
      location = Location.find(args[:id])
      location.update(location_name: args[:location_name], location_type: args[:location_type], parent_location: args[:parent_location], description: args[:description])
      {
        location: location,
        result: location.errors.blank?
      }
    end
  end
end
