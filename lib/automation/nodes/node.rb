module Automation
  module Nodes
    module Node
      attr_accessor :node_data_keys

      def self.included(base)
        before_save :save_node_data
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

      def create_info_accessors(attrs)
        attrs.each do |attr|
          attr_accessor "node_info_#{attr}".to_sym
        end
      end

      def create_stat_accessors(attrs)
        attrs.each do |attr|
          attr_reader attr.to_sym
        end

        attrs_const_str = attrs.class.to_s

        attrs.each do |attr|
          instance_eval <<-METHOD
            def node_status_#{attr}=(value)
              @node_status_#{attr} = value if #{attrs_const_str}['#{attr}'].include?(value)
            end
          METHOD

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
        else
          send(callable_info, v)
        end

      end

      def get_status_or_info(k)
        callable_status = "node_status_#{k}".to_sym
        callable_info = "node_info_#{k}".to_sym

        if self.method_defined?(callable_status)
          return send(callable_status)
        else
          return send(callable_info)
        end

      end

    end
  end
end
