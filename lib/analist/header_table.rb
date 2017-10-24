# frozen_string_literal: true

module Analist
  class HeaderTable
    def classes_table
      @classes_table ||= {}
    end

    def methods_table
      @methods_table ||= {}
    end

    def store_class(klass, scope:, superklass:)
      classes_table[klass.join('::')] = { scope: scope, superklass: superklass&.join('::') }
    end

    def store_method(method, klass, node)
      if methods_table.key?(method)
        methods_table[method][klass.join('::')] = node
      else
        methods_table[method] = { klass.join('::') => node }
      end
    end

    def retrieve_class(klass)
      classes_table[klass]
    end

    def retrieve_method(method, klass)
      methods_table[method][klass]
    end
  end
end
