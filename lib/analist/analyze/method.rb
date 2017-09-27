# frozen_string_literal: true

require_relative './constants'
require_relative './send'
require_relative '../ast/send_node'

module Analist
  module Analyze
    class Method
      attr_reader :def_node

      def initialize(def_node)
        @def_node = def_node
      end

      def errors
        @var_to_type_map = {}
        errors_for_node(def_node.body).flatten.compact
      end

      private

      def errors_for_node(node)
        case node.type
        when :begin
          handle_begin(node)
        when :send
          handle_send(node)
        when :lvasgn
          handle_local_variable_assignment(node)
        end
      end

      def handle_begin(node)
        node.children.map { |s| errors_for_node(s) }
      end

      def handle_send(node)
        Analist::Analyze::Send.new(Analist::AST::SendNode.new(node),
                                   var_to_type_map: @var_to_type_map).errors
      end

      def handle_local_variable_assignment(node)
        var = node.children[0]
        type = node.children[1].type
        @var_to_type_map[var] = type
        nil
      end
    end
  end
end
