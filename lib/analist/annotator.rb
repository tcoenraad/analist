# frozen_string_literal: true

require 'active_support/inflector'
require_relative './annotations'

module Analist
  module Annotator
    module_function

    def annotate(node, schema = nil)
      return node unless node.respond_to?(:type)

      case node.type
      when :begin
        annotate_begin(node, schema)
      when :send
        annotate_send(node, schema)
      when :array
        annotate_array(node, schema)
      when :int, :str, :const
        annotate_primitive(node)
      else
        raise(NotImplementedError, "Node type `#{node.type}` cannot be annotated")
      end
    end

    def annotate_begin(node, schema)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) }, nil)
    end

    def annotate_send(node, schema)
      _receiver, method, = node.children

      if Analist::Annotations.send_annotations.keys.include?(method)
        annotated_children = node.children.map { |n| annotate(n, schema) }
        return AnnotatedNode.new(
          node,
          annotated_children,
          Analist::Annotations.send_annotations[method].call(annotated_children)
        )
      end

      annotate_send_unknown_method(node, schema)
    end

    def annotate_send_unknown_method(node, schema) # rubocop:disable Metrics/AbcSize
      _receiver, method, = node.children
      annotated_children = node.children.map { |n| annotate(n, schema) }

      table_name = annotated_children.first.annotation.last[:type].to_s.downcase.pluralize
      if schema.table_exists?(table_name)
        return AnnotatedNode.new(
          node, annotated_children, [
            { type: annotated_children.first.annotation.last[:type], on: :instance }, [],
            schema[table_name].find_type_for(method.to_s)
          ]
        )
      end

      raise(NotImplementedError, "Method `#{method}` cannot be annotated")
    end

    def annotate_array(node, schema)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) }, [nil, [], Array])
    end

    def annotate_primitive(node)
      AnnotatedNode.new(node, node.children,
                        Analist::Annotations.primitive_annotations[node.type].call(node))
    end
  end
end
