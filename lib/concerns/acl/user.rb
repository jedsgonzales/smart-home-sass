module Concerns
  module Acl
    module User
      extend ActiveSupport::Concern

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
        delete: 24
      }.with_indifferent_access

      included do
        attr_accessor :permission_check_cache
      end

      # respond to methods named for acl access
      # e.g. can_view_other_users?
      def method_missing(m, args, &block)
        if respond_to?(:permission) && self.permission.is_a?(Numeric)
          # only do this if current instance has numeric permission property responder

          result = false

          # inititalize if we haven't
          permission_check_cache ||= {}.with_indifferent_access

          # check if already evaluated
          if permission_check_cache.has_key?(m)
            result = permission_check_cache[m]
          else
            keys = m.split('_')

            if keys.first == 'can' && keys.last.end_with?('?')
              keys.shift # removed `can` word
              keys[keys.size - 1] = keys.last.sub(/\?/, '') # remove `?` from last word

              base = keys.shift
              permission_check_cache[m] = check_permission(base, keys)
            end
          end

          if block_given?
            block.call result
          else
            result
          end

        else
          super # delegate
        end

      end

      def respond_to_missing?(method_name, include_private = false)
        keys = method_name.to_s.split('_')

        if keys.first == 'can' && keys.last.end_with?('?')
          keys.shift # removed `can` word
          keys[keys.size - 1] = keys.last.sub(/\?/, '') # remove `?` from last word

          base = UserAcl::ACL[keys.shift]
          perm = UserAcl::BASE_ACL[keys.shift]
          while keys.size > 0 && !perm.nil?
            perm = perm[keys.shift]
          end

          perks_val.nil?
        else
          super
        end
      end

      # can?('view_other_users')
      def can?(act_str)
        perm_accessor = "can_#{acl_str.to_s}?"
        if permission_check_cache.has_key?(perm_accessor)
          permission_check_cache[perm_accessor]
        else
          eval(perm_accessor)
        end

      end

      protected
      def check_permission(base, keys)
        placement = UserAcl::ACL[base]

        perks_val = UserAcl::BASE_ACL[keys.shift]
        while keys.size > 0 && !perks_val.nil?
          perks_val = perks_val[keys.shift]
        end

        if perks_val.nil?
          false
        else
          target_permission = perks_val << placement
          (target_permission & self.permission) == target_permission
        end

      end
    end

  end
end
