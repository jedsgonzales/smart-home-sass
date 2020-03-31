class ControlNode < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to :control_device, foreign_key: :device_id
  belongs_to :location, foreign_key: :location_id, optional: true
  has_many :node_statuses, foreign_key: :node_id
end
