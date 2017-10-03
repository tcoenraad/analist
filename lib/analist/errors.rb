# frozen_string_literal: true

module Analist
  class NoMethodError
    attr_reader :line

    def initialize(line, object:, method:)
      @line = line
      @object = object
      @method = method
    end

    def to_s
      "#{line} NoMethodError: undefined method `#{@method}' for #{@object}"
    end
  end

  class TypeError
    attr_reader :line, :expected_annotation, :actual_annotation

    def initialize(line, expected_annotation:, actual_annotation:)
      @line = line
      @expected_annotation = expected_annotation
      @actual_annotation = actual_annotation
    end

    def to_s
      "#{line} TypeError: #{expected_annotation} cannot be coerced into #{actual_annotation}"
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
