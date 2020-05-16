require 'automation/api_node'

class ControlNode < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to :control_device, foreign_key: :device_id
  belongs_to :control_node_profile, foreign_key: :node_profile_id, optional: true
  belongs_to :location, foreign_key: :location_id, optional: true

  has_many :node_statuses, foreign_key: :node_id

  before_save do |node|
    node.known_type = node.control_node_profile.node_type
  end

  validates :control_channel, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :device_id  }

  after_initialize do |node|
    if node.control_node_profile.present?
      if Automation::ApiNode::LIST.has_key?(node.control_node_profile.node_type)
        node.send(:extend, Automation::ApiNode::LIST[node.control_node_profile.node_type])
      else
        # default into relay
        node.send(:extend, Automation::ApiNode::LIST['Default'])
      end

    else
      # fallback to last known_type
      node.send(:extend, Automation::ApiNode::LIST[node.known_type])
    end
  end

end
