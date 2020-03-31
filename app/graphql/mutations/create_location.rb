module Mutations
  class CreateLocation < BaseMutation
    # arguments passed to the `resolved` method
    argument :location_name, String, required: true
    argument :location_type, Integer, required: true
    argument :description, String, required: true
    argument :parent_location, Integer, required: true

    # return type from the mutation
    type Types::LocationType

    def resolve(location_name: nil, location_type: nil, description: nil, parent_location: nil)
      Location.create!(
        location_name: location_name,
        location_type: location_type,
        description: description,
        parent_location: parent_location
      )
    end
  end
end