class CreateControlNodeProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :control_node_profiles, id: :uuid do |t|
      t.string :description, default: ''
      t.integer :control_channel, null: false
      t.string :node_type, null: false
      t.uuid :profile_id, null: false
      t.bigint :user_id, default: 0 # owner 0 is system

      t.timestamps
    end
  end
end
