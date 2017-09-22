# frozen_string_literal: true

module Analist
  module AST
    class Node
      attr_reader :value, :type

      def initialize(value:, type:)
        @value = value
        @type = type
      end
    end
  end
end
