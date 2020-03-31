class ControlDevice < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to :control_device_profile, foreign_key: :profile_id
  belongs_to :location, foreign_key: :location_id
  belongs_to :user, optional: true

end
