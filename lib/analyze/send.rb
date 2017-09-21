# frozen_string_literal: true

module Analyze
  class Send
    attr_reader :functions, :send_node

    def initialize(functions, send_node)
      @functions = functions
      @send_node = send_node
    end

    def line
      send_node.loc.line
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
      if method_missing? # rubocop:disable Style/GuardClause
        Analyze::NoMethodError.new(line, object: send_node.callee, method: send_node.name)
      end
    end

    def self.method_missing_map
      {
        hash: [:<<]
      }
    end

    private

    def argument_error?
      functions[send_node.name] && actual_number_of_args != expected_number_of_args
    end

    def method_missing?
      Send.method_missing_map.fetch(send_node.callee&.type, []).include?(send_node.name)
    end

    def expected_number_of_args
      functions[send_node.name].args.count
    end

    def actual_number_of_args
      send_node.args.count
    end
  end
end
