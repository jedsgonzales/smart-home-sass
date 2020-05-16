require 'automation/api'

class ControlDeviceProfile < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  has_many :control_node_profiles, -> { order(control_channel: :asc) }, foreign_key: :profile_id, dependent: :destroy
  has_many :control_devices, foreign_key: :profile_id, dependent: :nullify

  belongs_to :user, optional: true # profile can be built-in by the system, so it is optional

  validates :name, presence: true
  validates :model_code, presence: true
  validates :model_api, presence: true

  validate :has_node_profiles, :model_api_is_valid

  private
  def has_node_profiles
    self.errors.add(:base, 'node profiles are required') if self.control_node_profiles.empty?
  end

  def model_api_is_valid
    self.errors.add(:model_api, 'invalid api identification') unless Automation::Api::LIST.has_key?(self.model_api)
  end

end
