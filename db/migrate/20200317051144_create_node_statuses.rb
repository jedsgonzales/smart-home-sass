class CreateNodeStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :node_statuses, id: :uuid do |t|
      t.uuid :node_id, null: false
      t.string :name, null: false
      t.string :value, length: 16
      t.string :type
 
    end
  end
end
