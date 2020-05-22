require 'automation/api_node'

class ControlNode < ApplicationRecord
  default_scope -> { order("created_at DESC") }

  belongs_to        :control_device, foreign_key: :device_id
  belongs_to        :control_node_profile, foreign_key: :node_profile_id, optional: true
  belongs_to        :location, foreign_key: :location_id, optional: true

  has_many          :node_statuses, foreign_key: :node_id

  validates         :control_channel, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: [:device_id, :node_profile_id]  }

  after_initialize  :inject_api_node

  before_save do |node|
    node.known_type = node.control_node_profile.node_type
  end

  before_validation :check_if_profile_is_updated

  private
  def check_if_profile_is_updated
    inject_api_node if self.will_save_change_to_node_profile_id?
  end

  def inject_api_node
    if self.control_node_profile.present?
      if Automation::ApiNode::LIST.has_key?(self.control_node_profile.node_type)
        self.send(:extend, Automation::ApiNode::LIST[self.control_node_profile.node_type])
      else
        # default into relay
        self.send(:extend, Automation::ApiNode::LIST['Default'])
      end

    else
      # fallback to last known_type
      self.send(:extend, Automation::ApiNode::LIST[self.known_type])
    end
  end

end
