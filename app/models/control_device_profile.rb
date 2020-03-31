class ControlDeviceProfile < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  has_many :control_node_profiles, foreign_key: :profile_id, -> { order('control_channel ASC') }
  has_many :control_devices, foreign_key: :profile_id

  belongs_to :user, optional: true

  validates :name, presence: true
  validates :model_code, presence: true
end
