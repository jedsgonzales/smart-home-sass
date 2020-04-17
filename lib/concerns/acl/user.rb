require 'concerns/acl/base_acl'

module Concerns
  module Acl
    module User
      include Concerns::Acl::BaseAcl

      BASE_ACL = {
        other: {
          users: 1,
          locations: 2,
          organizations: 4
        },
        organization: {
          users: 8,
          locations: 16
        }
      }.with_indifferent_access

      ACL = {
        view: 0,
        create: 8,
        update: 16,
        delete: 24,
        moderate: 32
      }.with_indifferent_access

      def self.included(base)
        base.extend Concerns::Acl::BaseAclClassMethod
        base.setup_acl action_acl: Concerns::Acl::User::ACL, scope_acl: Concerns::Acl::User::BASE_ACL
      end
    end

  end
end
