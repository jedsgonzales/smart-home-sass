class ModifyControlNodesAndProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column      :control_nodes, :control_channel, :integer, null: false, after: 'node_profile_id'
  end
end
