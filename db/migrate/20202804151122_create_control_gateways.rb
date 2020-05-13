class CreateControlGateways < ActiveRecord::Migration[6.0]
  def change
    create_table :control_gateways, id: :uuid do |t|
      t.string :description
      t.string :ip_address
      t.string :subnet_mask
      t.string :comm_type # udp, tcp
      t.integer :port

      t.timestamps
    end
  end
end
