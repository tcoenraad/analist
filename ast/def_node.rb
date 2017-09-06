module AST
  class DefNode
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def name
      node.children.first
    end

    def args
      node.children[1]
    end

    def body
      node.children.last
    end
  end
end
