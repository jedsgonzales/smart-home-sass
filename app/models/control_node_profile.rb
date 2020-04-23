class ControlNodeProfile < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to  :control_device_profile, foreign_key: :profile_id

  has_many    :control_nodes, foreign_key: :node_profile_id, dependent: :nullify

  validates :control_channel, numericality: { only_integer: true, greater_than: 0 }
  validates :node_type, presence: true
  validates :profile_id, presence: true
end
