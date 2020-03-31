class ControlNodeProfile < ApplicationRecord
  default_scope -> { order("created_at DESC") }
  
  belongs_to :control_device_profile, foreign_key: :profile_id

  validates :control_channel, numericality: { only_integer: true, greater_than: 0 }
  validates :node_type, presense: true
  validates :profile_id, presense: true
end
