class UserOrganization < ApplicationRecord

  belongs_to :user, foreign_key: 'created_by'

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :main_locations, -> { where(parent_location: nil) }, class_name: 'Location'
  has_many :node_locations, -> { where.not(parent_location: nil) }, class_name: 'Location'
  has_many :control_devices, through: :users
  has_many :control_device_profiles, through: :users

  validates :name, presence: true

end
