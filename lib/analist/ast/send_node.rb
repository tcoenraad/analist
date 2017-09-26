# frozen_string_literal: true

require_relative './node'

module Analist
  module AST
    class SendNode
      extend Forwardable

      attr_reader :node, :receiver, :method, :args

      def_delegator :node, :loc

      def initialize(node)
        @node = node

        @receiver, @method, *@args = node.children
      end

      def parent
        self.class.new(receiver)
      end
    end
  end
end
