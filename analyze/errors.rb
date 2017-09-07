module Analyze
  class TypeError
    attr_reader :line

    def initialize(line, operator:)
      @line = line
      @operator = operator
    end
  end

  class ArgumentError
    attr_reader :line, :expected_number_of_args, :actual_number_of_args

    def initialize(line, expected_number_of_args:, actual_number_of_args:)
      @line = line
      @expected_number_of_args = expected_number_of_args
      @actual_number_of_args = actual_number_of_args
    end
  end
end
