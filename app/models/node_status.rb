class NodeStatus < ApplicationRecord
  default_scope -> { order("created_at DESC") }
  
  belongs_to :control_node, foreign_key: :node_id
end
