class CreateControlDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :control_devices, id: :uuid do |t|
      t.string :name, length: 128
      t.string :details, length: 256
      t.uuid :profile_id, null: false
      t.uuid :location_id
      t.bigint :user_id, default: 0 # owner 0 is system

      t.timestamps
    end
  end
end
