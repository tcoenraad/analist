# frozen_string_literal: true

module Analist
  module Analyze
    class Constants
      def self.primitive_types
        %i[int str]
      end

      def self.variable_types
        %i[lvar]
      end

      def self.method_missing_map
        {
          hash: [:<<]
        }
      end

      def self.coerce_error_map
        {
          :+ => {
            int: [[:str]],
            str: [[:int]],
            hash: [[:array]],
            array: [[:hash]]
          }
        }
      end

      def self.operator_aliases_map
        {
          :+ => :+,
          :- => :+,
          :* => :+,
          :/ => :+
        }
      end

      def self.ar_transform_map
        {
          collection: {
            all: :collection,
            first: :object
          }
        }
      end
    end
  end
end
