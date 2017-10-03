# frozen_string_literal: true

module Analist
  class AnnotatedNode
    extend Forwardable

    attr_reader :children, :annotation
    def_delegators :@node, :loc, :type

    def initialize(node, children, annotation)
      @node = node
      @children = children
      @annotation = annotation
    end
  end
end
