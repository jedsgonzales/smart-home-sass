class Location < ApplicationRecord
  default_scope -> { order("created_at DESC") }

	belongs_to :parent, :class_name =>  "Location", required: false
  belongs_to :organization, required: false

	has_many :sublocation, :class_name => "Location", :foreign_key => "parent_location", dependent: :destroy
  has_many :control_devices, dependent: :nullify
  has_many :control_nodes, dependent: :nullify

  enum location_types: { area: 0, unit: 1  }

	validates_uniqueness_of :location_name, scope: [:location_type, :parent_location], :case_sensitive => false, message: "already exist!"
end
