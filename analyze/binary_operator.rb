require_relative './errors'
require_relative './constants'

module Analyze
  class BinaryOperator
    attr_reader :statements, :type_map

    def initialize(statements, type_map)
      @statements = statements
      @type_map = type_map
    end

    def operator
      statements[1]
    end

    def left
      statements.first
    end

    def right
      statements.last
    end

    def errors
      return [] if Analyze::Coerce.check?(
        operator: operator,
        type: resolve_node_to_type(left),
        other_type: resolve_node_to_type(right)
      )

      line = left.loc.line
      [Analyze::TypeError.new(line, operator: operator)]
    end

    private

    def resolve_node_to_type(node)
      return type_map[node.children.first] if Constants.variable_types.include?(node.type)

      node.type
    end
  end
end
