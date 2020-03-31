class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :location_name
      t.integer :location_type
      t.string :description
      t.uuid :parent_location
      t.uuid :organization_id
      t.references :user

      t.timestamps
    end
  end
end
