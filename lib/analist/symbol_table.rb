# frozen_string_literal: true

module Analist
  class SymbolTable
    class << self
      def table
        @table ||= {}
      end

      def store(symbol, annotation)
        table[symbol] = annotation
      end

      def retrieve(symbol)
        table[symbol]
      end
    end
  end
end
