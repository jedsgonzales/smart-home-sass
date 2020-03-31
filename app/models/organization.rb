class UserOrganization < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :locations, -> { where(parent_location: nil) }
  has_many :control_devices, through: :users
  has_many :control_device_profiles, through: :users

  validates :name, presence: true
end
