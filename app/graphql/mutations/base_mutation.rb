require 'concerns/acl/graphql'

module Mutations
  #class BaseMutation < GraphQL::Schema::RelayClassicMutation
  #  argument_class Types::BaseArgument
  #  field_class Types::BaseField
  #  input_object_class Types::BaseInputObject
  #  object_class Types::BaseObject
  #end

  class BaseMutation < GraphQL::Schema::Mutation
    include Concerns::Acl::Graphql
    null false
  end
end
