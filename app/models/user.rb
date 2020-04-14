require 'concerns/acl/user'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User, Concerns::Acl::User

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

  # Find locations associated with the user instance given
  # with optional organization and/or parent location
  # (defaults to `{ organization_id: nil, parent_id: nil }`)
  #
  # @param opts [Hash] Options for query. Available options are
  #   `organization_id` and `parent_id`.
  #
  # @return [Array] An array of matching locations with the given criteria.
  #   If `organization_id` is given, it will return the locations
  #   under the organization where the user belongs to. If `parent_id`
  #   is given, it will return locations underneath that location.
  #   Providing both values must pass on both criteria
  #
  def locations(opts = { })
    organization_id = opts[:organization_id]
    parent_id = opts[:parent_id]

    if self.organizations.empty? && organization_id.empty?
      # return user created locations
      return parent_id.present? ?
        self.locations.includes(:main_locations, :node_locations).where(parent_location: parent_id) : self.locations.includes(:main_locations, :node_locations)

    else
      all_locations = []

      org_subjects = organization_id.empty? ?
        self.organizations.includes(:main_locations, :node_locations) :
        self.organizations.includes(:main_locations, :node_locations).where(id: organization_id)

      org_subjects.each do |organization|
        if parent_id.present?
          all_locations = all_locations + organization.node_locations.where(parent_location: parent_id).to_a
          break unless all_locations.empty?
        else
          all_locations = all_locations + organization.main_locations.to_a
        end
      end

      return all_locations
    end
  end

end
