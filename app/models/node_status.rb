class NodeStatus < ApplicationRecord
  belongs_to :control_node, foreign_key: :node_id
end
