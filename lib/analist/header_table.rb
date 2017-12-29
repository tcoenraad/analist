# frozen_string_literal: true

require 'ostruct'

module Analist
  class HeaderTable
    def self.read_from_file(filename)
      node = Analist.parse_file(filename)
      Headerizer.headerize([node])
    end

    def store_class(klass_name, scope: [], superklass: nil)
      full_klass_name = (scope + [klass_name]).join('::')
      classes_table[full_klass_name] = OpenStruct.new(scope: scope, superklass: superklass)
    end

    def store_mutation(identifier, type)
      mutations_table[identifier] = mutation_type_map.fetch(type, Annotation::TypeUnknown)
    end

    def store_method(method, scope, node)
      constant_name = scope.join('::')
      if methods_table.key?(method)
        methods_table[method][constant_name] = node
      else
        methods_table[method] = { constant_name => node }
      end
    end

    def retrieve_class(klass_name)
      classes_table[klass_name]
    end

    def retrieve_method(method, klass)
      node = methods_table.dig(method, klass)
      return node if node
      return unless (superklass = retrieve_class(klass)&.superklass)
      retrieve_method(method, superklass)
    end

    def retrieve_mutation(identifier)
      mutations_table[identifier]
    end

    private

    def classes_table
      @classes_table ||= {}
    end

    def methods_table
      @methods_table ||= {}
    end

    def mutations_table
      @mutations_table ||= {}
    end

    def mutation_type_map
      {
        array: Array,
        boolean: Analist::Annotation::Boolean,
        integer: Integer,
        hash: Hash,
        string: String
      }
    end
  end
end
