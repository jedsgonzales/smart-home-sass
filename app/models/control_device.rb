class ControlDevice < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to  :control_device_profile, foreign_key: :profile_id, optional: true
  belongs_to  :location, foreign_key: :location_id, optional: true
  belongs_to  :user, optional: true
  belongs_to  :control_gateway, optional: true

  has_many    :control_nodes, foreign_key: :device_id, dependent: :destroy

  validates :known_model_api, presence: true

  before_save do |device|
    if device.control_device_profile.present?
      if device.known_code.empty? ||
        (device.control_device_profile.model_code.present? && device.known_code != device.control_device_profile.model_code)

        device.known_code = device.control_device_profile.model_code
      end

      if device.known_model_api.empty? ||
        (device.control_device_profile.model_api.present? && device.known_model_api != device.control_device_profile.model_api)

        device.known_model_api = device.control_device_profile.model_api
      end
    end

  end
end
