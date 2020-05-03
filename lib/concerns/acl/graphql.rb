module Concerns
  module Acl
    module Graphql
      def auth_checkpoint(msg = 'unauthorized access')
        raise GraphQL::ExecutionError.new(msg, extensions: { code: 'AUTHENTICATION_ERROR' }) unless context[:current_user]
      end

      def deny_access(msg = 'access denied')
        raise GraphQL::ExecutionError.new(msg, extensions: { code: 'INSUFFICIENT_PRIVILEDGE' })
      end

      def raise_error(msg = 'error occurred', ext_code: 'GENERAL_ERROR')
        raise GraphQL::ExecutionError.new(msg, extensions: { code: ext_code })
      end
    end
  end
end
