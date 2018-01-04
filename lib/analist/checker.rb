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

    def check_send(node) # rubocop:disable Metrics/PerceivedComplexity
      return [Analist::DecorateWarning.new(node)] if node.annotation.hint ==
                                                     Analist::ResolveLookup::Hint::Decorate

      receiver, _method_name, *args = node.children
      args = args.reject { |arg| arg.type == :block_pass }

      errors = [check(receiver), args.map { |arg| check(arg) }].compact.flatten

      return errors if node.annotation.return_type[:type] == Analist::Annotation::TypeUnknown

      expected_annotation = node.annotation

      actual_annotation = Analist::Annotation.new(
        receiver&.annotation&.return_type, args.flat_map { |a| a.annotation.return_type },
        node.annotation.return_type
      )

      if significant_difference?(expected_annotation, actual_annotation)
        possible_error_count = if expected_annotation.args_types.is_a?(Set)
                                 expected_annotation.args_types.map(&:count)
                               else
                                 [expected_annotation.args_types.count]
                               end
        errors << if !possible_error_count.include?(actual_annotation.args_types.count)
                    Analist::ArgumentError.new(node, expected_number_of_args:
                                                       possible_error_count.uniq,
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
      return if [annotation.args_types, other_annotation.args_types].any? do |a|
        a.any? { |t| t == { type: Analist::Annotation::TypeUnknown } } ||
        a == [type: Analist::Annotation::AnyArgs]
      end

      return if %i[receiver_type return_type].any? do |field|
        annotation.send(field)[:type] == Analist::Annotation::TypeUnknown ||
        other_annotation.send(field)[:type] == Analist::Annotation::TypeUnknown
      end

      diff_args_types = significant_difference_on_args_types?(annotation.args_types,
                                                              other_annotation.args_types)
      diff_args_types || %i[receiver_type return_type].any? do |field|
        annotation.send(field) != other_annotation.send(field)
      end
    end

    def significant_difference_on_args_types?(args_types, other_args_types)
      return !args_types.member?(other_args_types) if args_types.is_a?(Set)

      return true if args_types.count != other_args_types.count
      !args_types.zip(other_args_types).all? do |a, o|
        a == o || (a[:type] == Analist::Annotation::AnyClass && o[:on] == :collection)
      end
    end
  end
end
