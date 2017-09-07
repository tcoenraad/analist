module AST
  class SendNode
    extend Forwardable

    attr_reader :node

    def_delegator :node, :loc

    def initialize(node)
      @node = node
    end

    def args
      node.children.drop(2)
    end

    def name
      node.children[1]
    end
  end
end
