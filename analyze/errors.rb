module Analyze
  class TypeError
    attr_reader :line

    def initialize(line, operator:)
      @line = line
      @operator = operator
    end

    def to_s
      "#{line} TypeError"
    end
  end

  class ArgumentError
    attr_reader :line, :expected_number_of_args, :actual_number_of_args

    def initialize(line, expected_number_of_args:, actual_number_of_args:)
      @line = line
      @expected_number_of_args = expected_number_of_args
      @actual_number_of_args = actual_number_of_args
    end

    def to_s
      "#{line} ArgumentError, expected #{expected_number_of_args}, "\
        "actual: #{actual_number_of_args}"
    end
  end
end
