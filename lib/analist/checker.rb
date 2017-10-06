# frozen_string_literal: true

require_relative './errors'

module Analist
  module Checker
    module_function

    def check(node)
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
        raise(NotImplementedError, "Node type `#{node.type}` cannot be checked")
      end
    end

    def check_begin(node)
      node.children.flat_map { |n| check(n) }.compact
    end

    def check_array(node)
      node.children.flat_map { |n| check(n) }.compact
    end

    def check_send(node) # rubocop:disable Metrics/AbcSize
      receiver, _method_name, *args = node.children
      expected_annotation = node.annotation
      actual_annotation = [
        receiver.annotation.last, args.flat_map { |a| a.annotation.last }, node.annotation.last
      ]

      if expected_annotation != actual_annotation
        if expected_annotation[1].count != actual_annotation[1].count
          error = Analist::ArgumentError.new(node.loc.line,
                                             expected_number_of_args: expected_annotation[1].count,
                                             actual_number_of_args:  actual_annotation[1].count)
        else
          error = Analist::TypeError.new(node.loc.line,
                                         expected_annotation: expected_annotation,
                                         actual_annotation: actual_annotation)
        end
      end

      [error, check(receiver), args.flat_map { |a| check(a) }.compact].compact.flatten
    end
  end
end
