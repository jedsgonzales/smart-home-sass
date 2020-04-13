class AddSystemRoleAtUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :system_role, :bigint, default: 0, after: 'userdata'
  end
end
