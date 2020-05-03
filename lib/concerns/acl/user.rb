require 'concerns/acl/base_acl'

module Concerns
  module Acl
    module User
      include Concerns::Acl::BaseAcl

      BASE_ACL = {
        system: {
          users: 1,
          organizations: 2
        },
        organization: {
          users: 16
        },
        everything: {
          here: 128
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
