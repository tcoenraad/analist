# frozen_string_literal: true

require 'analist/errors'
require 'analist/warnings'

module Analist
  module Checker
    module_function

    def check(node) # rubocop:disable Metrics/CyclomaticComplexity
      return [] unless node.respond_to?(:type)

      case node.type
      when :begin
        check_begin(node)
      when :block
        check_block(node)
      when :class
        check_class(node)
      when :def
        check_def(node)
      when :defs
        check_defs(node)
      when :if
        check_if(node)
      when :module
        check_module(node)
      when :send
        check_send(node)
      when :array
        check_array(node)
      when :int, :str, :const
        return
      else
        if ENV['ANALIST_DEBUG']
          raise NotImplementedError, "Node type `#{node.type}` cannot be checked"
        end
        []
      end
    end

    def check_array(node)
      check_children(node)
    end

    def check_begin(node)
      check_children(node)
    end

    def check_block(node)
      check_children(node)
    end

    def check_children(node)
      node.children.flat_map { |n| check(n) }.compact
    end

    def check_class(node)
      check_children(node)
    end

    def check_def(node)
      check_children(node)
    end

    def check_defs(node)
      check_children(node)
    end

    def check_if(node)
      check_children(node)
    end

    def check_module(node)
      check_children(node)
    end

    def check_send(node)
      return [Analist::DecorateWarning.new(node)] if node.annotation.hint ==
                                                     Analist::ResolveLookup::Hint::Decorate
      return [] if node.annotation.return_type[:type] == Analist::AnnotationTypeUnknown

      receiver, _method_name, *args = node.children
      expected_annotation = node.annotation

      actual_annotation = Analist::Annotation.new(
        receiver&.annotation&.return_type, args.flat_map { |a| a.annotation.return_type[:type] },
        node.annotation.return_type
      )

      if expected_annotation != actual_annotation
        error = if expected_annotation.args_types.count != actual_annotation.args_types.count
                  Analist::ArgumentError.new(node, expected_number_of_args:
                                                     expected_annotation.args_types.count,
                                                   actual_number_of_args:
                                                     actual_annotation.args_types.count)
                else
                  Analist::TypeError.new(node,
                                         expected_annotation: expected_annotation,
                                         actual_annotation: actual_annotation)
                end
      end

      [error, check(receiver), args.flat_map { |a| check(a) }.compact].compact.flatten
    end
  end
end
