require 'concerns/acl/graphql'

module Types::Queries
  class BaseQuery < GraphQL::Schema::Resolver
    include Concerns::Acl::Graphql
  end
end
