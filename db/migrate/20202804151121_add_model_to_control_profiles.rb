class AddModelToControlProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :control_device_profiles, :model_api, :string, null: false, after: 'model_code'
    add_column :control_devices, :known_model_api, :string, null: false, after: 'model_api'

    # where we store some non-standard parameters such as device_type
    add_column :control_devices, :api_model_params, :json, null: false, after: 'known_model_api'
  end
end
