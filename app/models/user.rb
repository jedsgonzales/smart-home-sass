class User < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  enum status: {
    unverified: 0,
    active: 1,
    suspended: 2,
    archived: 4
  }

  has_many :user_roles
  has_many :organizations, through: :user_roles
  has_many :owned_organizations, class_name: 'Organization', foreign_key: 'created_by'
  has_many :recruited_org_users, class_name: 'UserRole', foreign_key: 'recruited_by'

  has_many :locations
  has_many :control_device_profiles
  has_many :control_devices
end
