module Analyze
  class Method
    attr_reader :method

    def initialize(method)
      @method = method
    end

    def errors
      errors_for_statements(method.body).flatten.compact
    end

    def self.primitive_types
      %i[int str]
    end

    private

    def errors_for_statements(statements)
      return unless statements && statements.is_a?(Parser::AST::Node)

      case statements.type
      when :begin
        handle_begin(statements)
      when :send
        handle_send(statements)
      end
    end

    def handle_begin(statements)
      statements.children.map { |s| errors_for_statements(s) }
    end

    def handle_send(statements)
      first_child = statements.children.first
      if first_child && self.class.primitive_types.include?(first_child.type)
        Analyze::BinaryOperator.new(statements.children).errors
      else
        statements.children.map { |s| errors_for_statements(s) }
      end
    end
  end
end
