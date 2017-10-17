# frozen_string_literal: true

require 'active_support/inflector'
require 'analist/annotations'
require 'analist/symbol_table'

module Analist
  module Annotator
    module_function

    def annotate(node, schema = nil) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
      return node unless node.respond_to?(:type)

      case node.type
      when :begin
        annotate_begin(node, schema)
      when :block
        annotate_block(node, schema)
      when :args
        annotate_args(node, schema)
      when :send
        annotate_send(node, schema)
      when :array
        annotate_array(node, schema)
      when :lvasgn
        annotate_local_variable_assignment(node, schema)
      when :lvar
        annotate_local_variable(node, schema)
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
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, schema) },
                        Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown))
    end

    def annotate_block(node, schema)
      SymbolTable.enter_scope
      block = annotate_begin(node, schema)
      SymbolTable.exit_scope
      block
    end

    def annotate_args(node, schema)
      annotate_begin(node, schema)
    end

    def annotate_send(node, schema) # rubocop:disable Metrics/AbcSize
      _receiver, method, = node.children

      if Analist::Annotations.send_annotations.keys.include?(method)
        annotated_children = node.children.map { |n| annotate(n, schema) }
        receiver_return_type = annotated_children.first.annotation.return_type[:type]
        return AnnotatedNode.new(
          node,
          annotated_children,
          Analist::Annotations.send_annotations[method].call(receiver_return_type) ||
            Analist::Annotation.new(receiver_return_type, Analist::AnnotationTypeUnknown,
                                    Analist::AnnotationTypeUnknown)
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

    def annotate_local_variable_assignment(node, schema)
      annotated_children = node.children.map { |n| annotate(n, schema) }
      variable, value = annotated_children

      SymbolTable.store(variable, value.annotation)

      AnnotatedNode.new(node, annotated_children,
                        Analist::Annotation.new(nil, [], value.annotation.return_type[:type]))
    end

    def annotate_local_variable(node, schema)
      annotated_children = node.children.map { |n| annotate(n, schema) }
      AnnotatedNode.new(node, annotated_children,
                        SymbolTable.retrieve(annotated_children.first))
    end

    def annotate_primitive(node)
      AnnotatedNode.new(node, node.children,
                        Analist::Annotations.primitive_annotations[node.type].call(node))
    end

    def lookup_return_type_from_schema(annotated_children, schema)
      return unless schema
      return unless annotated_children.first

      _receiver, method = annotated_children

      table_name = annotated_children.first.annotation.return_type[:type].to_s.downcase.pluralize
      schema[table_name].lookup_type_for_method(method.to_s) if schema.table_exists?(table_name)
    end
  end
end
