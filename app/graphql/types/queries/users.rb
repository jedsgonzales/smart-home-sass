module Types::Queries
  class Users < BaseQuery
    argument :organization_id, ID, required: false

    type [Types::Objects::UserType], null: false

    def resolve(organization_id: nil)
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "CREDS_INVALID"
      end

      if context[:current_user].can_view_other_users?

        if organization_id.nil?
          User.include(:user_roles).where(user_roles: { organization_id: organization_id })
        else
          User.all
        end

      else
        raise GraphQL::ExecutionError, "INSUFFICIENT_PRIVILEDGE"
      end


    end
  end
end
