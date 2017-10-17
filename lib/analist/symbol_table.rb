# frozen_string_literal: true

module Analist
  class SymbolTable
    class << self
      def table
        @table ||= { 0 => {} }
      end

      def level
        @level ||= 0
      end

      def store(symbol, annotation)
        table[level][symbol] = annotation
      end

      def retrieve(symbol, l = level)
        return if l.negative?

        if table[l].key?(symbol)
          table[l][symbol]
        else
          retrieve(symbol, l - 1)
        end
      end

      def enter_scope
        @level = level + 1
        table[level] = {}
      end

      def exit_scope
        table.delete(level)
        @level = level - 1
      end
    end
  end
end
