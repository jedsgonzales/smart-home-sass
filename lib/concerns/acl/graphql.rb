module Concerns
  module Acl
    module Graphql
      def auth_checkpoint(msg = 'unauthorized access')
        raise GraphQL::ExecutionError.new(msg, extensions: { code: 'AUTHENTICATION_ERROR' }) unless context[:current_user]
      end

      def deny_access(msg = 'access denied')
        raise GraphQL::ExecutionError.new(msg, extensions: { code: 'INSUFFICIENT_PRIVILEDGE' })
      end
    end
  end
end
