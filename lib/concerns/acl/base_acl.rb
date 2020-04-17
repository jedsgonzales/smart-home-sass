module Concerns
  module Acl
    module BaseAcl
      extend ActiveSupport::Concern

      SCOPE_ACL = {
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

      ACTION_ACL = {
        view: 0,
        create: 8,
        update: 16,
        delete: 24
      }.with_indifferent_access

      def self.included(k)
        k.extend Concerns::Acl::BaseAclClassMethod
      end

      attr_accessor :permission_check_cache

      # respond to methods named for acl access
      # e.g. can_view_other_users?
      def method_missing(m, args = nil, &block)
        if respond_to?(:system_role) && self.system_role.is_a?(Numeric)
          # only do this if current instance has numeric permission property responder

          result = false

          # inititalize if we haven't
          permission_check_cache ||= {}.with_indifferent_access

          # check if already evaluated
          if permission_check_cache.has_key?(m)
            result = permission_check_cache[m]
          else
            keys = m.to_s.split('_')

            if keys.first == 'can' && keys.last.end_with?('?')
              keys.shift # removed `can` word
              keys[keys.size - 1] = keys.last.sub(/\?/, '') # remove `?` from last word

              base = keys.shift
              result = permission_check_cache[m] = check_permission(base, keys)
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
        Rails.logger.debug "ACL respond_to_missing #{method_name.to_s}"

        keys = method_name.to_s.split('_')

        if keys.first == 'can' && keys.last.end_with?('?')
          keys.shift # removed `can` word
          keys[keys.size - 1] = keys.last.sub(/\?/, '') # remove `?` from last word

          # puts "#{self} #{self.class} respond_to_missing"

          base = self.class.action_acl[keys.shift]
          perm = self.class.scope_acl[keys.shift]
          while keys.size > 0 && !perm.nil?
            perm = perm[keys.shift]
          end

          !perm.nil?
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
        # puts "#{self} #{self.class} check_permission"
        #Rails.logger.debug "ACL check_permission #{base} #{keys}"
        #Rails.logger.debug "ACL system_role #{self.system_role}"

        placement = self.class.action_acl[base]
        perks_val = self.class.scope_acl[keys.shift]
        while keys.size > 0 && !perks_val.nil?
          perks_val = perks_val[keys.shift]
        end

        if perks_val.nil?
          false
        else
          target_permission = perks_val << placement

          #Rails.logger.debug "ACL target_permission #{target_permission}"
          #Rails.logger.debug "ACL result #{(target_permission & self.system_role)}"

          (target_permission & self.system_role) == target_permission
        end
      end
    end

    module BaseAclClassMethod
      def setup_acl(opts = {})
        #puts "#{self} setup_acl"

        self.action_acl = opts[:action_acl] || Concerns::Acl::BaseAcl::ACTION_ACL
        self.scope_acl = opts[:scope_acl] || Concerns::Acl::BaseAcl::SCOPE_ACL
      end

      def action_acl
        #puts "#{self} ACTION ACL is #{v}"
        @action_acl
      end

      def action_acl=(v)
        #puts "#{self} ACTION ACL updated to #{v}"
        @action_acl = v
      end

      def scope_acl
        #puts "#{self} SCOPE ACL is #{v}"
        @scope_acl
      end

      def scope_acl=(v)
        #puts "#{self} SCOPE ACL updated to #{v}"
        @scope_acl = v
      end

    end

  end
end
