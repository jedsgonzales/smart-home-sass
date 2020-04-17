require 'concerns/acl/base_acl'

module Concerns
  module Acl
    module UserRole
      include Concerns::Acl::BaseAcl

      BASE_ACL = {
        organization: {
          instance: 1,
          users: 2,
          locations: 4
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
        base.setup_acl action_acl: Concerns::Acl::UserRole::ACL, scope_acl: Concerns::Acl::UserRole::BASE_ACL
      end
    end

  end
end
