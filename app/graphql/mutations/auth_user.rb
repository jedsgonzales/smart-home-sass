module Mutations
  class AuthUser < BaseMutation
    null true

    argument        :email, String, required: true
    argument        :password, String, required: true

    field           :auth_result, Types::Objects::AuthResultType, null: true
    field           :uid, String, null: false

    def resolve(email: nil, password: nil)
      user = User.find_by_email(email)

      if user.present? && user.valid_password?(password)
        # check if user already logged, return the old client token
        if context[:current_user].present? && user == context[:current_user]
          client = context[:auth_headers]['client']
          token = user.tokens[client].merge( client: client )

        else
          token = DeviseTokenAuth::TokenFactory.create
          user.tokens[token.client] = {
            token:  token.token_hash,
            expiry: token.expiry
          }
          user.save!

        end

        {
          auth_result: token,
          uid: user.uid
        }

      else # invalid credentials
        raise GraphQL::ExecutionError, "INVALID_CRED"

      end

    end
  end
end
