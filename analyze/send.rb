module Analyze
  class Send
    attr_reader :functions, :func

    def initialize(functions, func)
      @functions = functions
      @func = func
    end

    def inspect!
      return if functions[func.name].args.count == func.args.count
      line = func.loc.line
      Analyze::ArgumentError.new(line, actual_number_of_args: func.args.count, expected_number_of_args: functions[func.name].args.count)
    end
  end
end
