# frozen_string_literal: true

require 'active_support/inflector'
require 'analist/annotations'
require 'analist/resolve_lookup'
require 'analist/symbol_table'

module Analist
  module Annotator
    UNKNOWN_ANNOTATION_TYPE = Analist::Annotation.new(Analist::AnnotationTypeUnknown,
                                                      Analist::AnnotationTypeUnknown,
                                                      Analist::AnnotationTypeUnknown).freeze

    module_function

    def annotate(node, resources = {}) # rubocop:disable Metrics/CyclomaticComplexity
      resources[:symbol_table] ||= SymbolTable.new

      return node unless node.respond_to?(:type)

      case node.type
      when :args
        annotate_args(node, resources)
      when :begin
        annotate_begin(node, resources)
      when :block
        annotate_block(node, resources)
      when :class
        annotate_class(node, resources)
      when :module
        annotate_module(node, resources)
      when :def
        annotate_def(node, resources)
      when :defs
        annotate_defs(node, resources)
      when :send
        annotate_send(node, resources)
      when :array
        annotate_array(node, resources)
      when :lvasgn
        annotate_local_variable_assignment(node, resources)
      when :lvar
        annotate_local_variable(node, resources)
      when :int, :str, :const, :dstr
        annotate_primitive(node)
      else
        if ENV['ANALIST_DEBUG']
          raise NotImplementedError, "Node type `#{node.type}` cannot be annotated"
        end
        AnnotatedNode.new(node, node.children, UNKNOWN_ANNOTATION_TYPE)
      end
    end

    def annotate_args(node, resources)
      annotate_begin(node, resources)
    end

    def annotate_array(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Array))
    end

    def annotate_begin(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown))
    end

    def annotate_block(node, resources, name = nil)
      resources[:symbol_table].enter_scope(name)
      block = annotate_begin(node, resources)
      resources[:symbol_table].exit_scope
      block
    end

    def annotate_class(node, resources)
      annotate_block(node, resources, node.children.first.children[1])
    end

    def annotate_def(node, resources)
      annotate_block(node, resources, node.children.first)
    end

    def annotate_defs(node, resources)
      annotate_block(node, resources, :"self.#{node.children[1]}")
    end

    def annotate_local_variable_assignment(node, resources)
      annotated_children = node.children.map { |n| annotate(n, resources) }
      variable, value = annotated_children

      resources[:symbol_table].store(variable, value.annotation)

      AnnotatedNode.new(node, annotated_children,
                        Analist::Annotation.new(nil, [], value.annotation.return_type))
    end

    def annotate_local_variable(node, resources)
      annotated_children = node.children.map { |n| annotate(n, resources) }
      AnnotatedNode.new(node, annotated_children,
                        resources[:symbol_table].retrieve(annotated_children.first) ||
                        UNKNOWN_ANNOTATION_TYPE)
    end

    def annotate_module(node, resources)
      AnnotatedNode.new(node, node.children.map { |n| annotate(n, resources) },
                        Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown))
    end

    def annotate_primitive(node)
      AnnotatedNode.new(node, node.children,
                        Analist::Annotations.primitive_annotations[node.type].call(node))
    end

    def annotate_send(node, resources)
      _receiver, method, = node.children

      if Analist::Annotations.send_annotations.keys.include?(method)
        annotated_children = node.children.map { |n| annotate(n, resources) }

        if annotated_children.first.nil?
          return AnnotatedNode.new(node, annotated_children, UNKNOWN_ANNOTATION_TYPE)
        end

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

      receiver_type = annotated_receiver&.annotation&.return_type

      return_type = Analist::ResolveLookup::Headers.new(annotated_children, resources).return_type
      return_type ||= Analist::ResolveLookup::Schema.new(annotated_children, resources).return_type
      return_type ||= AnnotationTypeUnknown

      AnnotatedNode.new(node, annotated_children,
                        Analist::Annotation.new(receiver_type, args, return_type))
    end
  end
end
