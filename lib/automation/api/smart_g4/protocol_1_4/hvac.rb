module Automation
  module Api
    module SmartG4
      module Protocol_1_4
        module Hvac
          def hvac_ctrl_resp(message)
            self.control_nodes.each do |control_node|
              if control_node.is_a?(Automation::Nodes::Hvac) && control_node.control_channel == message.content[0]
                control_node.node_status_temp_unit = message.content[1]
                control_node.node_status_ac_status = message.content[8]
                control_node.node_status_curr_temp = message.content[2]
                control_node.node_status_cool_set_point = message.content[3]
                control_node.node_status_heat_set_point = message.content[4]
                control_node.node_status_auto_set_point = message.content[5]
                control_node.node_status_mode = message.content[7] >> 4 # high nimble
                control_node.node_status_fan = message.content[7] & 0x0F # low nimble
              end
            end
          end
        end
      end
    end
  end
end
