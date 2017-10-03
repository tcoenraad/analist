# frozen_string_literal: true

require_relative './errors'

module Analist
  module Checker
    def check(node) # rubocop:disable Metrics/MethodLength
      return node unless node.respond_to?(:type)

      case node.type
      when :begin
        check_begin(node)
      when :send
        check_send(node)
      when :int, :str, :const
        return
      else
        raise(NotImplementedError, "Node type `#{node.type}` cannot be checked")
      end
    end

    def check_begin(node)
      node.children.map { |n| check(n) }
    end

    def check_send(node)
      receiver, _method_name, *args = node.children
      actual_annotation = [receiver.annotation.last, args.flat_map { |a| a.annotation.last }, node.annotation.last]
      expected_annotation = node.annotation

      if expected_annotation != actual_annotation
        type_error = Analist::TypeError.new(node.loc.line,
                                            expected_annotation: expected_annotation,
                                            actual_annotation: actual_annotation)
      end

      [type_error, check(receiver), args.flat_map { |a| check(a) }].flatten.compact
    end
  end
end
