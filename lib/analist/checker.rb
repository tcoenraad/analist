# frozen_string_literal: true

require 'analist/errors'

module Analist
  module Checker
    module_function

    def check(node) # rubocop:disable Metrics/CyclomaticComplexity
      return node unless node.respond_to?(:type)

      case node.type
      when :begin
        check_begin(node)
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
      end
    end

    def check_begin(node)
      node.children.flat_map { |n| check(n) }.compact
    end

    def check_array(node)
      node.children.flat_map { |n| check(n) }.compact
    end

    def check_send(node) # rubocop:disable Metrics/AbcSize
      return if node.annotation.return_type[:type].is_a?(Analist::AnnotationTypeUnknown)

      receiver, _method_name, *args = node.children
      expected_annotation = node.annotation
      actual_annotation = Analist::Annotation.new(
        receiver.annotation.return_type, args.flat_map { |a| a.annotation.return_type[:type] },
        node.annotation.return_type
      )

      if expected_annotation != actual_annotation
        error = if expected_annotation.args_types.count != actual_annotation.args_types.count
                  Analist::ArgumentError.new(node.loc.line, expected_number_of_args:
                                                     expected_annotation.args_types.count,
                                                            actual_number_of_args:
                                                     actual_annotation.args_types.count)
                else
                  Analist::TypeError.new(node.loc.line,
                                         expected_annotation: expected_annotation,
                                         actual_annotation: actual_annotation)
                end
      end

      [error, check(receiver), args.flat_map { |a| check(a) }.compact].compact.flatten
    end
  end
end
