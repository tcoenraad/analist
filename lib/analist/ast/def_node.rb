# frozen_string_literal: true

module Analist
  module AST
    class DefNode
      extend Forwardable

      attr_reader :node, :name, :args, :body

      def_delegator :node, :loc

      def initialize(node)
        @node = node
        @name, @args, @body = node.children
      end
    end
  end
end
