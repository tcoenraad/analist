# frozen_string_literal: true

require 'active_support/inflector'

module Analist
  module Annotator
    module_function

    def annotate(node, schema) # rubocop:disable Metrics/MethodLength
      return node unless node.respond_to?(:type)

      case node.type
      when :begin
        annotate_begin(node, schema)
      when :send
        annotate_send(node, schema)
      when :int
        annotate_int(node)
      when :str
        annotate_str(node)
      when :const
        annotate_const(node)
      else
        raise(NotImplementedError, "Node type `#{node.type}` cannot be annotated")
      end
    end

    def annotate_begin(node, schema)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) }, nil)
    end

    def annotate_send(node, schema)
      _receiver, method, = node.children
      case method
      when :+
        annotate_send_plus(node, schema)
      when :all
        annotate_send_all(node, schema)
      when :first
        annotate_send_first(node, schema)
      when :id
        annotate_send_id(node, schema)
      when :reverse
        annotate_send_reverse(node, schema)
      else
        raise(NotImplementedError, "Method `#{method}` cannot be annotated")
      end
    end

    def annotate_send_plus(node, schema)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) }, [Integer, [Integer], Integer])
    end

    def annotate_send_id(node, schema)
      annotated_children = node.children.map { |n| annotate(n, schema) }

      AnnotatedNode.new(node, annotated_children, [{ type: children.first.annotation.last[:type], on: :instance }, [], Integer])
    end

    def annotate_send_reverse(node, schema)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) }, [String, [], String])
    end

    def annotate_send_all(node, schema)
      annotated_children = node.children.map { |n| annotate(n, schema) }
      AnnotatedNode.new(node, annotated_children, [{ type: children.first.annotation.last[:type], on: :collection }, [],  { type: children.first.annotation.last[:type], on: :collection }])
    end

    def annotate_send_first(node, schema)
      annotated_children = node.children.map { |n| annotate(n, schema) }
      AnnotatedNode.new(node, annotated_children, [{ type: children.first.annotation.last[:type], on: :collection }, [], { type: children.first.annotation.last[:type], on: :instance }])
    end

    def annotate_const(node)
      AnnotatedNode.new(node, node.children, [nil, [], { type: node.children.last, on: :collection }])
    end

    def annotate_int(node)
      AnnotatedNode.new(node, node.children, [nil, [], Integer])
    end

    def annotate_str(node)
      AnnotatedNode.new(node, node.children, [nil, [], String])
    end
  end
end
