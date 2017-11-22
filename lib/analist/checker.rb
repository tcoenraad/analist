# frozen_string_literal: true

require 'analist/errors'
require 'analist/warnings'

module Analist
  module Checker
    module_function

    def check(node)
      return [] unless node.is_a?(Analist::AnnotatedNode)

      case node.type
      when :send
        check_send(node)
      else
        check_children(node)
      end
    end

    def check_children(node)
      node.children.flat_map { |n| check(n) }.compact
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
