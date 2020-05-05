module Types::Queries
  class Users < BaseQuery
    argument :organization_id, ID, required: false

    type [Types::Objects::UserType], null: false

    def resolve(organization_id: nil)
      auth_checkpoint

      if context[:current_user].can_view_system_users?

        if organization_id.nil?
          User.all
        else
          User.includes(:user_roles).where(user_roles: { organization_id: organization_id })
        end

      else
        deny_access
      end


    end
  end
end
