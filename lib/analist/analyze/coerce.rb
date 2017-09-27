# frozen_string_literal: true

module Analist
  module Analyze
    class Coerce
      def initialize(operator:, type:, args:, var_to_type_map: {})
        @operator = operator
        @type = type
        @args = args
        @var_to_type_map = var_to_type_map
      end

      def error?
        error_type = Constants.coerce_error_map.fetch(operator, {})[@type]
        return true if error_type && error_type.to_set.include?(arg_types)
        false
      end

      def arg_types
        @args.map do |arg|
          if arg.type == :lvar
            @var_to_type_map.fetch(arg.children.first, arg.type)
          else
            arg.type
          end
        end
      end

      def operator
        Constants.operator_aliases_map[@operator]
      end
    end
  end
end
