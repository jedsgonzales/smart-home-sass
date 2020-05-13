class AddGatewayToControlDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :control_devices, :control_gateway_id, :uuid, null: false, after: 'api_model_params'
  end
end
