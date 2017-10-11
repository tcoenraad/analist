# frozen_string_literal: true

require 'active_support/inflector'
require 'analist/annotations'

module Analist
  module Annotator
    module_function

    def annotate(node, schema = nil) # rubocop:disable Metrics/CyclomaticComplexity
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
        if ENV['ANALIST_DEBUG']
          raise NotImplementedError, "Node type `#{node.type}` cannot be annotated"
        end
        node
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

    def annotate_send_unknown_method(node, schema)
      _receiver, _method, *args = node.children
      annotated_children = node.children.map { |n| annotate(n, schema) }

      if annotated_children.first
        receiver_type = annotated_children.first.annotation.return_type[:type]
      end

      return_type = lookup_return_type_from_schema(annotated_children, schema) ||
                    AnnotationTypeUnknown

      AnnotatedNode.new(node, annotated_children,
                        Analist::Annotation.new(receiver_type, args, return_type))
    end

    def annotate_array(node, schema)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) },
                        Analist::Annotation.new(nil, [], Array))
    end

    def annotate_primitive(node)
      AnnotatedNode.new(node, node.children,
                        Analist::Annotations.primitive_annotations[node.type].call(node))
    end

    def lookup_return_type_from_schema(annotated_children, schema)
      return unless schema

      _receiver, method = annotated_children

      table_name = annotated_children.first.annotation.return_type[:type].to_s.downcase.pluralize
      schema[table_name].lookup_type_for_method(method.to_s) if schema.table_exists?(table_name)
    end
  end
end
