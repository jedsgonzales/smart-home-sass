class CreateUserOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :short_name, default: ''
      t.text :details, default: '', length: 512
      t.string :site_url, default: '', length: 256
      t.string :address, default: '', length: 256
      t.string :contact_details, length: 256

      t.boolean :private_info, default: false
      t.boolean :public_list, default: true
      t.bigint  :created_by, null: false

      t.timestamps
    end

    create_table :user_roles, id: :uuid do |t|
      t.bigint :user_id, null: false
      t.bigint :organization_id, null: false
      t.bigint :recruited_by, null: false
      t.boolean :user_joined, default: false
      t.timestamp :user_joined_at, null: true

      t.string :role_desc, default: ''
      t.json :role_data, default: {}.to_json

      t.timestamps
    end
  end
end
