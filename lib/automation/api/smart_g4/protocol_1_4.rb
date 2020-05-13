require 'resolv'
require 'automation/api/smart_g4'

module Automation
  module Api
    module SmartG4
      module Protocol_1_4
        # class utility to check if packet
        # can be processed by this Protocol
        # packet should be array of bytes
        def self.can_process_packet?(packet)
          does_it = false

          packet.each_with_index do |content, index|
            # detect lead code and msg length
            if ( contents[index, Automation::Api::SmartG4::PACKET[:lead_code].size ] == Automation::Api::SmartG4::PACKET[:lead_code] &&
                contents[index + Automation::Api::SmartG4::PACKET[:lead_code].size ] != nil)

              msg_length = contents[index + Automation::Api::SmartG4::PACKET[:lead_code].size]

              if contents.size >= (index + (Automation::Api::SmartG4::PACKET[:lead_code].size - 1) + msg_length)
                does_it = true
                break
              end
            end
          end

          does_it
        end

        #INSTANCE METHODS

        # message - a Message Object
        def receive(message)
          unless respond_to?(:api_model_params)
            raise Exception.new "Does not implement api_model_params accessor"
          end

          if (self.api_model_params[:device_id] != message.origin_device_id ||
              self.api_model_params[:subnet_id] != message.origin_subnet)
              # message not for this device
              return false
          end

          unless respond_to?(:control_nodes)
            raise Exception.new "Does not implement control_nodes accessor"
          end

          # this device can only be acknowledged from this IP
          # to make it process the packet, disassociate it from the gateway
          if message.origin_ip.present?
            if self.control_gateway.present? && message.origin_ip != self.control_gateway.ip_address
              return false
            end
          end

          op_codes = Automation::Api::SmartG4::PACKET[:op_codes]

          case message.op_code
            when op_codes[:relay][:power_crtl] # this command code
            when op_codes[:relay][:power_resp]
              relay_power_resp(message)
            else
              # unknown
          end # case
        end # receive

        def relay_power_resp(message)
          if message.content[1] == Automation::Api::SmartG4::PACKET[:success]
            ch_updates = { message.content[0] => message.content[2] } # record target channel

            # content byte 4 to 6
            other_channel_stats = message.content[4, 3]
            other_channel_stats.each_with_index do |set, index|
              for i in 0..7
                ch_num = i + (index * 8)

                if ch_num == message.content[0] # insert update unless orginal target
                  ch_updates[ch_num] = ((set1 > i) & 1)
                  mapped += 1
                end
              end
            end

            # call channel updates
            self.control_nodes.each do |control_node|
              is_switch = control_node.is_a?(Automation::Nodes::Switch)
              is_var_switch = control_node.is_a?(Automation::Nodes::VarVoltControl)

              if (is_switch || is_var_switch)
                  && ch_updates.has_key?(control_node.control_channel)

                power_status = ch_updates[control_node.control_channel]

                if message.content[0] == control_node.control_channel || is_switch
                  # absolute update because this is the target
                  control_node.node_status_power = power_status
                else # is_var_switch
                  # a little doubt because other updates are only flags if it is on or off (1 or 0)
                  # take over with highest value if powered on
                  control_node.node_status_power = ((power_status > 0) && (control_node.node_status_power > power_status)) ? control_node.node_status_power : power_status
                end
              end
            end

          end
        end # relay_power_resp
      end
    end
  end
end
