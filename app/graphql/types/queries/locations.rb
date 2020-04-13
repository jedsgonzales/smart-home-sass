module Types::Queries
  class Locations < BaseQuery
    argument :parent_id, ID, required: false
    argument :organization_id, ID, required: false
    argument :user_id, ID, required: false

    type [Types::Objects::LocationType], null: true

    def resolve(user_id: nil, organization_id: nil, parent_id: nil)
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "CREDS_INVALID"
      end

      # is querying owned locations ?
      if user_id.nil? || context[:current_user].id == user_id
        context[:current_user].locations(organization_id: organization_id, parent_id: parent_id)

      else # is querying someone else's locations ?
        # check rights before proceeding
        if context[:current_user].can_view_other_locations?

          if user_id == 0
            # query locations
            Location.where(parent_location: parent_id)
          else
            # query user's data
            user = User.find_by(id: user_id)
            user.locations(organization_id: organization_id, parent_id: parent_id) unless user.nil?
          end

        else
          raise GraphQL::ExecutionError, "INSUFFICIENT_PRIVILEDGE"
        end

      end

    end
  end
end
