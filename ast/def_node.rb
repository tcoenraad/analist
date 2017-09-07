module AST
  class DefNode
    extend Forwardable

    attr_reader :node

    def_delegator :node, :loc

    def initialize(node)
      @node = node
    end

    def name
      node.children.first
    end

    def args
      node.children[1].children
    end

    def body
      node.children.last
    end
  end
end
