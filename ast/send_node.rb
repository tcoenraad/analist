module AST
  class SendNode
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def args
      node.children[2]
    end

    def name
      node.children[1]
    end
  end
end
