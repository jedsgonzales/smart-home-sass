class AddFieldsToControlProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :control_nodes, :known_type, :string, default: 'Default', after: 'node_profile_id'
    add_column :control_devices, :known_code, :string, default: '', after: 'profile_id'
  end
end
