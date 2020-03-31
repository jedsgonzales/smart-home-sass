module Types::Queries
  class Users < BaseQuery
    type [Types::Objects::UserType], null: false

    def resolve
      if context[:current_user].nil?
        raise GraphQL::ExecutionError, "CREDS_INVALID"
      end

      User.all
    end
  end
end
