# frozen_string_literal: true

module Analist
  module AST
    class SendNode
      extend Forwardable

      attr_reader :node, :receiver, :method, :args

      def_delegators :node, :loc, :type

      def initialize(node)
        @node = node
        @receiver, @method, *@args = node.children
      end
    end
  end
end
