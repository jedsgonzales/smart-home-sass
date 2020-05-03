class ControlDeviceProfile < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  has_many :control_node_profiles, foreign_key: :profile_id, -> { order('control_channel ASC') }, dependent: :destroy
  has_many :control_devices, foreign_key: :profile_id, dependent: :nullify

  belongs_to :user, optional: true # profile can be built-in by the system, so it is optional

  validates :name, presence: true
  validates :model_code, presence: true
  validates :model_api, presence: true

  validate :validate_if_has_node_profiles

  private
  def validate_if_has_node_profiles
    self.errors.add(:base, 'node profiles are required') if self.control_node_profiles.empty?
  end
end
