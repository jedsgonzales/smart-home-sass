module Automation
  module Api
    module SmartG4
      module Protocol_1_4
        module Relay
          def relay_periodic_status(message)
            #puts "relay_periodic_status #{message.content}"
            relay_binary_status(message.content[3, 4])
          end # relay_periodic_status

          def relay_power_resp(message)
            # drop processing failures
            if message.content[1] == Automation::Api::SmartG4::PACKET[:failure]
              # ignore for now
              return false
            end

            relay_binary_status(message.content[4, 3], { message.content[0] => message.content[2] })
          end # relay_power_resp

          def relay_binary_status(byte_set, given = {})
            #puts "relay_binary_status #{byte_set}"
            ch_updates = given.dup # record target channel

            # content byte 4 to 6
            other_channel_stats = byte_set
            other_channel_stats.each_with_index do |set, index|
              #puts "evaluating byte #{set.to_s(16)}"
              for i in 0..7
                ch_num = i + (index * 8) + 1

                unless ch_updates.has_key?(ch_num) # insert update unless orginal target
                  ch_updates[ch_num] = ((set >> i) & 1)
                  #puts "channel #{ch_num} status #{ch_updates[ch_num]}"
                end
              end
            end

            # call channel updates
            self.control_nodes.each do |control_node|
              is_switch = control_node.is_a?(Automation::Nodes::Switch)
              is_var_switch = control_node.is_a?(Automation::Nodes::VarVoltControl)

              if ((is_switch || is_var_switch) &&
                  ch_updates.has_key?(control_node.control_channel))

                power_status = ch_updates[control_node.control_channel]

                if given.has_key?(control_node.control_channel) || is_switch
                  # absolute update because this is the target
                  control_node.node_status_power = (is_switch && power_status > 0) ? 100 : power_status
                  #puts " -> channel #{control_node.control_channel} switch set to #{control_node.node_status_power}"
                else # is_var_switch
                  # a little doubt because other updates are only flags if it is on or off (1 or 0)
                  # take over with highest value if powered on
                  control_node.node_status_power = ((power_status > 0) && (control_node.node_status_power > power_status)) ? control_node.node_status_power : power_status
                  #puts " -> channel #{control_node.control_channel} var switch set to #{control_node.node_status_power}"
                end
              end
            end
          end # relay_binary_status

          def relay_resp_channel_status(message)
            #puts "relay_resp_channel_status #{message.content}"
            channels = message.content[0]

            ch_updates = {}
            for i in 1..(channels)
              #puts "update channel #{i} = #{message.content[i]}"
              ch_updates[i] = message.content[i]
            end

            self.control_nodes.each do |control_node|
              is_switch = control_node.is_a?(Automation::Nodes::Switch)
              is_var_switch = control_node.is_a?(Automation::Nodes::VarVoltControl)

              if ((is_switch || is_var_switch) && ch_updates.has_key?(control_node.control_channel))
                #puts "update channel #{control_node.control_channel} will update to #{ch_updates[control_node.control_channel]}"
                control_node.node_status_power = ch_updates[control_node.control_channel]
                #puts "update channel #{control_node.control_channel} updated to #{control_node.node_status_power}"
              end
            end
          end # relay_resp_channel_status
        end
      end
    end
  end
end
