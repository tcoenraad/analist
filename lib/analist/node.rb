# frozen_string_literal: true

module Analist
  class Node < Parser::AST::Node
    attr_reader :filename

    def assign_properties(properties)
      super(properties)

      @filename = properties[:filename]
    end
  end
end
