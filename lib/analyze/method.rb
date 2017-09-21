# frozen_string_literal: true

require_relative './constants'

module Analyze
  class Method
    attr_reader :def_node, :type_map

    def initialize(def_node)
      @def_node = def_node
    end

    def errors
      @type_map = {}
      errors_for_statements(def_node.body).flatten.compact
    end

    private

    def errors_for_statements(statements)
      return unless statements && statements.is_a?(Parser::AST::Node)

      case statements.type
      when :begin
        handle_begin(statements)
      when :send
        handle_send(statements)
      when :lvasgn
        handle_local_variable_assignment(statements)
      end
    end

    def handle_begin(statements)
      statements.children.map do |s|
        errors_for_statements(s)
      end
    end

    def handle_send(statements)
      first_child = statements.children.first
      if first_child && Constants.primitive_types.include?(first_child.type)
        Analyze::BinaryOperator.new(statements.children, type_map).errors
      else
        statements.children.map { |s| errors_for_statements(s) }
      end
    end

    def handle_local_variable_assignment(statements)
      name = statements.children[0]
      type = statements.children[1].type
      type_map[name] = type
      nil
    end
  end
end
