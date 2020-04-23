class ControlDevice < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to  :control_device_profile, foreign_key: :profile_id, optional: true
  belongs_to  :location, foreign_key: :location_id, optional: true
  belongs_to  :user, optional: true

  has_many    :control_nodes, foreign_key: :device_id, dependent: :destroy

  before_save do |device|
    device.known_code = device.control_device_profile.model_code
  end
end
