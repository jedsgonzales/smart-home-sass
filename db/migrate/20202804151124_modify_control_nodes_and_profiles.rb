class ModifyControlNodesAndProfiles < ActiveRecord::Migration[6.0]
  def change
    remove_column   :control_node_profiles, :control_channel
    add_column      :control_nodes, :control_channel, :integer, null: false, after: 'node_profile_id'
  end
end
