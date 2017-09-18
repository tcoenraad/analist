require_relative './errors'

module Analyze
  class BinaryOperator
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end

    def operator
      statements[1]
    end

    def left
      statements.first
    end

    def right
      statements.last
    end

    def errors
      return [] if Analyze::Coerce.check?(
        operator: operator,
        type: left.type,
        other_type: right.type
      )

      line = left.loc.line
      [Analyze::TypeError.new(line, operator: operator)]
    end
  end
end
