module Types::Queries
  class NodeClasses < BaseQuery
    type [String], null: false

    def resolve
      Automation::NodeList::MAP.keys
    end
  end
end
