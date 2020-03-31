module Mutations
  class DeleteLocation < BaseMutation
    # TODO: define return fields
    field :location, Types::LocationType, null: false
    field :result, Boolean, null: true

    # TODO: define arguments
    argument :id, ID, required: true

    # TODO: define resolve method

    def resolve(**args)
      location = Location.find(args[:id])
      location.destroy
      {
        location: location,
        result: location.errors.blank?
      }
    end
  end
end
