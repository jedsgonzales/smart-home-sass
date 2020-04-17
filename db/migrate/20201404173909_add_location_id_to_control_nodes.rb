class AddLocationIdToControlNodes < ActiveRecord::Migration[6.0]
  def change
    add_column :control_nodes, :location_id, :uuid, default: nil, after: 'device_id'
  end
end
