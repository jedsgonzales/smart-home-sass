class CreateControlDeviceProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :control_device_profiles, id: :uuid do |t|
      t.string :name, null: false
      t.string :description, length: 512
      t.string :model_code, null: false
      t.bigint :user_id, default: 0 # owner 0 is system

      t.timestamps
    end
  end
end
