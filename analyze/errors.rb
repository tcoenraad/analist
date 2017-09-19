# frozen_string_literal: true

module Analyze
  class NoMethodError
    attr_reader :line

    def initialize(line, object:, method:)
      @line = line
      @object = object
      @method = method
    end

    def to_s
      "#{line} NoMethodError: undefined method `#{@method}' for #{@object}'"
    end
  end

  class TypeError
    attr_reader :line

    def initialize(line, left_type:, right_type:, operator:)
      @line = line
      @left_type = left_type
      @right_type = right_type
      @operator = operator
    end

    def to_s
      "#{line} TypeError: #{@left_type} cannot be coerced into #{@right_type}"
    end
  end

  class ArgumentError
    attr_reader :line

    def initialize(line, expected_number_of_args:, actual_number_of_args:)
      @line = line
      @expected_number_of_args = expected_number_of_args
      @actual_number_of_args = actual_number_of_args
    end

    def to_s
      "#{line} ArgumentError, expected #{@expected_number_of_args}, "\
        "actual: #{@actual_number_of_args}"
    end
  end
end
