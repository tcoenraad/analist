# frozen_string_literal: true

module Analyze
  class Send
    attr_reader :functions, :func

    def initialize(functions, func)
      @functions = functions
      @func = func
    end

    def line
      func.loc.line
    end

    def errors
      [no_method_error, argument_error].compact
    end

    def argument_error
      return unless argument_error?
      Analyze::ArgumentError.new(line,
                                 actual_number_of_args: actual_number_of_args,
                                 expected_number_of_args: expected_number_of_args)
    end

    def no_method_error
      Analyze::NoMethodError.new(line, object: func.callee, method: func.name) if method_missing?
    end

    def self.method_missing_map
      {
        hash: [:<<]
      }
    end

    private

    def argument_error?
      functions[func.name] && actual_number_of_args != expected_number_of_args
    end

    def method_missing?
      Send.method_missing_map.fetch(func.callee&.type, []).include?(func.name)
    end

    def expected_number_of_args
      functions[func.name].args.count
    end

    def actual_number_of_args
      func.args.count
    end
  end
end
