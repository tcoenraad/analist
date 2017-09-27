# frozen_string_literal: true

module Analist
  module AST
    class ConstNode
      extend Forwardable

      attr_reader :node

      def_delegator :node, :loc

      def initialize(node)
        @node = node
        _, @klass = node.children
      end

      def active_record_model_name
        @klass.to_s.downcase
      end
    end
  end
end
