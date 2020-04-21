require 'active_support/concern'


module Automation
  module Nodes
    module NodeClassMethods
      def create_accessors(klass, info_attr, stats_attr)
        create_info_accessors(klass, info_attr)
        create_stat_accessors(klass, stats_attr)
      end

      def create_callbacks(klass, info_attr_str, stats_attr_str)
        if klass.ancestors.include?(ActiveRecord::Base)
          klass.class_eval <<-METHOD
            before_save :save_node_data
            after_find do
              self.load_node_data( (#{info_attr_str} + #{stats_attr_str}).keys.uniq )
            end

            after_initialize do
              self.node_status_ref = #{stats_attr_str}
            end
          METHOD
        end
      end

      def create_stat_accessors(base, attrs)
        attrs_const_str = attrs.class.to_s

        attrs.each do |attr_key, attr_vals|
          attr = attr_key.to_s

          base.class_eval <<-METHOD
            def node_status_#{attr}=(value)
              @node_status_#{attr} = value if node_status_ref.has_key?(:#{attr}) && node_status_ref[:#{attr}].include?(value)
            end

            def node_status_#{attr}
              @node_status_#{attr}
            end
          METHOD
        end
      end

      def create_info_accessors(base, attrs)
        attrs.each do |attr|
          base.attr_accessor "node_info_#{attr}".to_sym
        end
      end
    end

    module Node
      extend ActiveSupport::Concern

      attr_accessor :node_data_keys

      def node_status_ref
        @node_status_ref
      end

      def node_status_ref=(v)
        @node_status_ref = v
      end


      def save_node_data
        if self.respond_to?(:node_statuses) # expects relation collection, or array
          for_updating = node_data_keys.clone
          node_statuses.each do |node_status_obj|
            for_updating.each do |node_status_key|
              node_status_key_str = node_status_key.to_s

              if node_status_obj.name == node_status_key_str
                node_status_obj.value = get_status_or_info(node_status_key_str)

                for_updating.delete(node_status_key) # reduce the heap
                break # break to proceed to next status
              end

            end

          end

        elsif self.respond_to?(:node_data=)
          node_data = serialized_data

        else
          Rails.logger.warn("No node_data column or node_statuses relation found for #{self}. Unable to populate status.")
        end
      end

      def load_node_data(attrs = nil)
        node_data_keys = attrs

        if self.respond_to?(:node_statuses) # expects relation collection, or array
          self.node_statuses.each do |node_status|
            update_status_or_info(node_status.name, node_status.value)

          end

        elsif self.respond_to?(:node_json_data) # expects a json data
          serialized_data = node_data

        else
          Rails.logger.warn("No node_data column or node_statuses relation found for #{self}. Unable to populate status.")
        end
      end

      def serialized_data
        if node_data_keys.nil?
          {}.to_json
        else
          Hash[ node_data_keys.map{ |attr| [ attr, self.method_defined?("node_status_#{attr}".to_sym) ? send("node_status_#{attr}") : send("node_info_#{attr}") ] } ].to_json
        end

      end

      def serialized_data=(json_data)
        JSON.parse(json_data).each do |k, v|
          update_status_or_info(k, v)
        end

      end

      protected
      def update_status_or_info(k, v)
        callable_status = "node_status_#{k}=".to_sym
        callable_info = "node_info_#{k}=".to_sym

        if self.method_defined?(callable_status)
          send(callable_status, v)
        elsif self.method_defined?(callable_info)
          send(callable_info, v)
        end

      end

      def get_status_or_info(k)
        callable_status = "node_status_#{k}".to_sym
        callable_info = "node_info_#{k}".to_sym

        if self.method_defined?(callable_status)
          send(callable_status)
        elsif self.method_defined?(callable_info)
          send(callable_info)
        else
          nil
        end

      end

    end
  end
end
