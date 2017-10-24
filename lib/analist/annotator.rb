# frozen_string_literal: true

require 'active_support/inflector'
require 'analist/annotations'
require 'analist/symbol_table'

module Analist
  module Annotator
    module_function

    def annotate(node, resources = nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/LineLength
      return node unless node.respond_to?(:type)

      case node.type
      when :begin
        annotate_begin(node, resources)
      when :block
        annotate_block(node, resources)
      when :class
        annotate_class(node, resources)
      when :module
        annotate_module(node, resources)
      when :args
        annotate_args(node, resources)
      when :send
        annotate_send(node, resources)
      when :array
        annotate_array(node, resources)
      when :lvasgn
        annotate_local_variable_assignment(node, resources)
      when :lvar
        annotate_local_variable(node, resources)
      when :int, :str, :const
        annotate_primitive(node)
      else
        if ENV['ANALIST_DEBUG']
          raise NotImplementedError, "Node type `#{node.type}` cannot be annotated"
        end
        node
      end
    end

    def annotate_args(node, resources)
      annotate_begin(node, resources)
    end

    def annotate_begin(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown))
    end

    def annotate_block(node, resources)
      SymbolTable.enter_scope
      block = annotate_begin(node, resources)
      SymbolTable.exit_scope
      block
    end

    def annotate_module(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown))
    end

    def annotate_class(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown))
    end

    def annotate_send(node, resources) # rubocop:disable Metrics/AbcSize
      _receiver, method, = node.children

      if Analist::Annotations.send_annotations.keys.include?(method)
        annotated_children = node.children.map { |n| annotate(n, resources) }
        receiver_return_type = annotated_children.first.annotation.return_type[:type]
        return AnnotatedNode.new(
          node,
          annotated_children,
          Analist::Annotations.send_annotations[method].call(receiver_return_type) ||
            Analist::Annotation.new(receiver_return_type, Analist::AnnotationTypeUnknown,
                                    Analist::AnnotationTypeUnknown)
        )
      end

      annotate_send_unknown_method(node, resources)
    end

    def annotate_send_unknown_method(node, resources)
      annotated_children = node.children.map { |n| annotate(n, resources) }
      annotated_receiver, _method, *args = annotated_children

      receiver_type = annotated_receiver.annotation.return_type if annotated_receiver

      return_type = lookup_return_type_from_headers(annotated_children, resources[:headers]) ||
                    lookup_return_type_from_schema(annotated_children, resources[:schema]) ||
                    AnnotationTypeUnknown

      AnnotatedNode.new(node, annotated_children,
                        Analist::Annotation.new(receiver_type, args, return_type))
    end

    def annotate_array(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Array))
    end

    def annotate_local_variable_assignment(node, resources)
      annotated_children = node.children.map { |n| annotate(n, resources) }
      variable, value = annotated_children

      SymbolTable.store(variable, value.annotation)

      AnnotatedNode.new(node, annotated_children,
                        Analist::Annotation.new(nil, [], value.annotation.return_type[:type]))
    end

    def annotate_local_variable(node, resources)
      annotated_children = node.children.map { |n| annotate(n, resources) }
      AnnotatedNode.new(node, annotated_children,
                        SymbolTable.retrieve(annotated_children.first))
    end

    def annotate_primitive(node)
      AnnotatedNode.new(node, node.children,
                        Analist::Annotations.primitive_annotations[node.type].call(node))
    end

    def lookup_return_type_from_headers(annotated_children, headers)
      return unless headers
      return unless annotated_children.first

      receiver, method = annotated_children
      klass_name = receiver.annotation.return_type[:type].to_s

      last_statement = headers.methods_table.dig(method, klass_name)&.children&.last
      annotate(last_statement).annotation.return_type if last_statement
    end

    def lookup_return_type_from_schema(annotated_children, schema)
      return unless schema
      return unless annotated_children.first

      receiver, method = annotated_children

      table_name = receiver.annotation.return_type[:type].to_s.downcase.pluralize
      schema[table_name].lookup_type_for_method(method.to_s) if schema.table_exists?(table_name)
    end
  end
end
