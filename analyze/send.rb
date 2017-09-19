# frozen_string_literal: true

module Analyze
  class Send
    attr_reader :functions, :func

    def initialize(functions, func)
      @functions = functions
      @func = func
    end

    def errors
      actual_number_of_args = func.args.count
      expected_number_of_args = functions[func.name].args.count

      return [] if actual_number_of_args == expected_number_of_args
      line = func.loc.line
      [Analyze::ArgumentError.new(line,
                                  actual_number_of_args: actual_number_of_args,
                                  expected_number_of_args: expected_number_of_args)]
    end
  end
end
