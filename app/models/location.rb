class Location < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  scope :child_locations, -> { where.not(parent_location: nil) }

	belongs_to :parent, :class_name =>  "Location", foreign_key: :parent_location, required: false
  belongs_to :organization, required: false

  has_many :control_devices, dependent: :nullify
  has_many :control_nodes, dependent: :nullify

  has_many :sub_locations, :class_name => "Location", :foreign_key => "parent_location",
    dependent: :destroy, after_add: :add_organization_to_sub_location

  enum location_types: { area: 0, unit: 1  }

	validates_uniqueness_of :location_name, scope: [:location_type, :parent_location], :case_sensitive => false, message: "already exist!"

  private
  def add_organization_to_sub_location(sub_location)
    sub_location.organization = self.organization unless self.organization.nil?
  end
end
