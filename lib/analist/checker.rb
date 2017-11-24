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
      expected_args = node.annotation.args_types.flat_map do |a|
        a.respond_to?(:annotation) ? a.annotation.return_type[:type] : a
      end
      expected_annotation = Analist::Annotation.new(node.annotation.receiver_type,
                                                    expected_args, node.annotation.return_type)

      actual_annotation = Analist::Annotation.new(
        receiver&.annotation&.return_type, args.flat_map { |a| a.annotation.return_type[:type] },
        node.annotation.return_type
      )

      if significant_difference?(expected_annotation, actual_annotation)
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

    # rubocop:disable Metrics/LineLength
    def significant_difference?(annotation, other_annotation) # rubocop:disable Metrics/CyclomaticComplexity
      attrs = %i[receiver_type args_types return_type]
      attrs.delete(:args_types) if annotation.args_types.any? { |t| t == Analist::AnnotationTypeUnknown } ||
                                   annotation.args_types == [Analist::AnyArgs] ||
                                   other_annotation.args_types.any? { |t| t == Analist::AnnotationTypeUnknown } ||
                                   other_annotation.args_types == [Analist::AnyArgs]
      %i[receiver_type return_type].each do |field|
        attrs.delete(field) if annotation.send(field)[:type] == Analist::AnnotationTypeUnknown ||
                               other_annotation.send(field)[:type] == Analist::AnnotationTypeUnknown
      end

      attrs.any? do |attr|
        annotation.send(attr) != other_annotation.send(attr)
      end
    end
    # rubocop:enable Metrics/LineLength
  end
end
