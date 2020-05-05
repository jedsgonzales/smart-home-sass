require 'automation/node_list'

class ControlNode < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to :control_device, foreign_key: :device_id
  belongs_to :control_node_profile, foreign_key: :node_profile_id, optional: true
  belongs_to :location, foreign_key: :location_id, optional: true

  has_many :node_statuses, foreign_key: :node_id

  before_save do |node|
    node.known_type = device.control_node_profile.node_type
  end

  after_initialize do |node|
    if control_node_profile.present?
      if Automation::NodeList::MAP.has_key?(control_node_profile.node_type)
        node.send(:extend, Automation::NodeList::MAP[control_node_profile.node_type])
      else
        # default into relay
        node.send(:extend, Automation::NodeList::MAP['Default'])
      end

    else
      # fallback to last known_type
      node.send(:extend, Automation::NodeList::MAP[node.known_type])
    end
  end

end
