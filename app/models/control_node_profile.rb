require 'automation/api_node'

class ControlNodeProfile < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to  :control_device_profile, foreign_key: :profile_id

  has_many    :control_nodes, foreign_key: :node_profile_id, dependent: :nullify

  validates   :node_type, presence: true
  validates   :control_channel, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: [:profile_id, :node_type]  }

  validate    :node_type_is_valid

  private
  def node_type_is_valid
    self.errors.add(:model_api, 'invalid node type') unless Automation::ApiNode::LIST.has_key?(self.node_type)
  end
end
