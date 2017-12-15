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

      receiver, _method_name, *args = node.children
      args = args.reject { |arg| arg.type == :block_pass }

      errors = [check(receiver), args.map { |arg| check(arg) }].compact.flatten

      return errors if node.annotation.return_type[:type] == Analist::Annotation::TypeUnknown

      expected_args = node.annotation.args_types
      expected_annotation = Analist::Annotation.new(node.annotation.receiver_type,
                                                    expected_args, node.annotation.return_type)

      actual_annotation = Analist::Annotation.new(
        receiver&.annotation&.return_type, args.flat_map { |a| a.annotation.return_type[:type] },
        node.annotation.return_type
      )

      if significant_difference?(expected_annotation, actual_annotation)
        possible_error_count = expected_annotation.args_types.is_a?(Set) ? expected_annotation.args_types.map(&:count) : [expected_annotation.args_types.count]
        errors << if !possible_error_count.include?(actual_annotation.args_types.count)
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

      errors
    end

    def significant_difference?(annotation, other_annotation)
      attrs = %i[receiver_type args_types return_type]
      attrs.delete(:args_types) if [annotation, other_annotation].any? do |a|
        a.args_types.any? { |t| t == Analist::Annotation::TypeUnknown } ||
        a.args_types == [Analist::Annotation::AnyArgs]
      end
      %i[receiver_type return_type].each do |field|
        attrs.delete(field) if annotation.send(field)[:type] == Analist::Annotation::TypeUnknown ||
                               other_annotation.send(field)[:type] ==
                               Analist::Annotation::TypeUnknown
      end

      attrs.any? do |attr|
        if annotation.send(attr).is_a?(Set)
          return !annotation.send(attr).member?(other_annotation.send(attr))
        end
        annotation.send(attr) != other_annotation.send(attr)
      end
    end
  end
end
