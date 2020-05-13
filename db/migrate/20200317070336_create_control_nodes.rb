class CreateControlNodes < ActiveRecord::Migration[6.0]
  def change
    create_table :control_nodes, id: :uuid do |t|
      t.uuid    :device_id, null: false
      t.uuid    :node_profile_id, null: false
      t.string  :details, length: 256

      t.timestamps
    end
  end
end
