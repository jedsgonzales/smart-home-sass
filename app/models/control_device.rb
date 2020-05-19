class ControlDevice < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to    :control_device_profile, foreign_key: :profile_id, optional: true
  belongs_to    :location, foreign_key: :location_id, optional: true
  belongs_to    :user, optional: true
  belongs_to    :control_gateway, optional: true

  has_many      :control_nodes, foreign_key: :device_id, dependent: :destroy

  validates     :known_model_api, presence: true
  validate      :validate_by_api

  after_initialize  :init_api_model_params, :inject_protocol_api
  before_validation :set_last_knowns, :inject_protocol_api

  private
  # custom validations
  def validate_by_api
    if self.control_device_profile.present?
      if Automation::Api::LIST.has_key?(self.control_device_profile.model_api)
        Automation::Api::LIST[self.control_device_profile.model_api]::Validators.control_device(self)
      else
        Automation::Api::LIST[self.known_model_api]::Validators.control_device(self) unless Automation::Api::LIST[self.known_model_api].nil?
      end

    else
      # fallback to last known_type
      Automation::Api::LIST[self.known_model_api]::Validators.control_device(self) unless Automation::Api::LIST[self.known_model_api].nil?
    end
  end
  # end custom validations

  ######################

  # start hooks
  def init_api_model_params
    self.api_model_params ||= { device_id: 1, subnet_id: 1, device_type: 1 }
  end

  def inject_protocol_api
    if self.control_device_profile.present?
      if Automation::Api::LIST.has_key?(self.control_device_profile.model_api)
        self.send(:extend, Automation::Api::LIST[self.control_device_profile.model_api])
      else
        self.send(:extend, Automation::Api::LIST[self.known_model_api]) unless self.known_model_api.blank?
      end

    else
      # fallback to last known_type
      self.send(:extend, Automation::Api::LIST[self.known_model_api]) unless self.known_model_api.blank?
    end

  end

  def set_last_knowns
    if self.control_device_profile.present?
      if self.known_code.blank? ||
        (self.control_device_profile.model_code.present? && self.known_code != self.control_device_profile.model_code)

        self.known_code = self.control_device_profile.model_code
      end

      if self.known_model_api.blank? ||
        (self.control_device_profile.model_api.present? && self.known_model_api != self.control_device_profile.model_api)

        self.known_model_api = self.control_device_profile.model_api
      end
    end
  end
  # end hooks

end
