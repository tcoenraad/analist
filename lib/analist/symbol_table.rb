# frozen_string_literal: true

module Analist
  class SymbolTable
    def table
      @table ||= { 0 => {} }
    end

    def level
      @level ||= 0
    end

    def scope
      @scope ||= []
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

    def enter_scope(name = nil)
      scope << name
      @level = level + 1
      table[level] = {}
    end

    def exit_scope
      scope.pop
      table.delete(level)
      @level = level - 1
    end
  end
end
