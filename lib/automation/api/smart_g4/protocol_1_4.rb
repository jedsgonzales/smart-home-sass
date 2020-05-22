require 'resolv'
require 'automation/api/smart_g4'
require 'automation/api/smart_g4/protocol_1_4/relay'
require 'automation/api/smart_g4/protocol_1_4/hvac'

module Automation
  module Api
    module SmartG4
      module Protocol_1_4
        include Relay
        include Hvac

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

          if (self.api_model_params["device_id"] != message.origin_device_id ||
              self.api_model_params["subnet_id"] != message.origin_subnet)
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

          # puts "message op_code #{message.op_code_val}"
          # packet digestion router
          op_codes = Automation::Api::SmartG4::PACKET[:op_codes]
          case message.op_code_val
            when op_codes[:relay][:power_crtl] # this command code
            when op_codes[:relay][:power_resp]
              relay_power_resp(message)
            when op_codes[:relay][:read_channel_status]
            when op_codes[:relay][:resp_channel_status]
              relay_resp_channel_status(message)
            when op_codes[:relay][:periodic_status]
              relay_periodic_status(message)
            when op_codes[:hvac][:ctrl_cmd]
            when op_codes[:hvac][:ctrl_resp]
              hvac_ctrl_resp(message)
            else
              # unknown
          end # case

          return true
        end # receive

        # API Validators
        module Validators
          def self.control_device(device)
            device.errors.add(:base, 'Subnet ID is required.') if device.api_model_params["subnet_id"].blank? || device.api_model_params["subnet_id"] == 0
            device.errors.add(:base, 'Device ID is required.') if device.api_model_params["device_id"].blank? || device.api_model_params["device_id"] == 0
            device.errors.add(:base, 'Device Type Code is required.') if device.api_model_params["device_type"].blank? || device.api_model_params["device_type"] == 0
          end
        end
        # /API Validators
      end
    end
  end
end
