# frozen_string_literal: true

require_relative './send_resolver'
require_relative './errors'

module Analist
  module Analyze
    class Send
      attr_reader :send_node

      def initialize(send_node, var_to_type_map: {}, schema: nil)
        @send_node = send_node
        @var_to_type_map = var_to_type_map
        @schema = schema
      end

      def line
        send_node.loc.line
      end

      def errors
        [no_method_error, argument_error, type_error].compact
      end

      def argument_error
        return unless argument_error?
        Analyze::ArgumentError.new(line,
                                   actual_number_of_args: actual_number_of_args,
                                   expected_number_of_args: expected_number_of_args)
      end

      def no_method_error
        return unless method_missing?
        Analyze::NoMethodError.new(line, object: send_node.receiver, method: send_node.method)
      end

      def type_error
        return unless type_error?
        Analyze::TypeError.new(line,
                               left_type: send_node.type,
                               right_type: send_node.args.map(&:type))
      end

      private

      def argument_error?
        expected_number_of_args && actual_number_of_args != expected_number_of_args
      end

      def method_missing?
        Constants.method_missing_map.fetch(send_node.receiver&.type, []).include?(send_node.method)
      end

      def type_error?
        return true if SendResolver.new(send_node, @schema, var_to_type_map: @var_to_type_map)
                                   .type_error?
        false
      end

      def resolve_receiver_type
        TypeResolver.new(send_node.receiver, @schema).resolve_receiver
      end

      def expected_number_of_args
        @var_to_type_map[send_node.method] && @var_to_type_map[send_node.method].args.children.count
      end

      def actual_number_of_args
        send_node.args.count
      end
    end
  end
end
