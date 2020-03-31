module Types::Queries
  class Locations < BaseQuery
    type [Types::Objects::LocationType], null: false

    def resolve
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "CREDS_INVALID"
      end

      Location.all
    end
  end
end
