# frozen_string_literal: true

module AST
  class SendNode
    extend Forwardable

    attr_reader :node

    def_delegator :node, :loc

    def initialize(node)
      @node = node
    end

    def callee
      node.children[0]
    end

    def args
      node.children.drop(2)
    end

    def name
      node.children[1]
    end
  end
end
