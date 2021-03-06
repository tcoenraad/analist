# frozen_string_literal: true

require 'analist/header_table'

module Analist
  module Headerizer
    module_function

    def headerize(nodes)
      header_table = HeaderTable.new
      nodes.each do |node|
        find_headers(node, header_table)
      end
      header_table
    end

    def find_headers(node, header_table, scope = []) # rubocop:disable Metrics/CyclomaticComplexity
      return unless node

      case node.type
      when :begin
        headerize_begin(node, header_table, scope)
      when :class
        headerize_class(node, header_table, scope)
      when :def
        headerize_def(node, header_table, scope)
      when :defs
        headerize_defs(node, header_table, scope)
      when :module
        headerize_module(node, header_table, scope)
      when :block
        headerize_block(node, header_table, scope)
      end
    end

    def headerize_begin(node, header_table, scope)
      node.children.map { |n| find_headers(n, header_table, scope) }
    end

    def headerize_class(node, header_table, scope)
      klass, superklass, body = node.children
      namespace = to_namespace(klass)
      header_table.store_class(namespace.last,
                               scope: scope + namespace[0..-2],
                               superklass: to_namespace(superklass).join('::'))
      find_headers(body, header_table, scope + namespace)
    end

    def headerize_def(node, header_table, scope)
      method, = node.children
      header_table.store_method(method, scope, node)
    end

    def headerize_defs(node, header_table, scope)
      _scope, method = node.children
      header_table.store_method(:"self.#{method}", scope, node)
    end

    def headerize_module(node, header_table, scope)
      namespace, body = node.children
      find_headers(body, header_table, scope + to_namespace(namespace))
    end

    def headerize_block(node, header_table, scope) # rubocop:disable Metrics/AbcSize
      klass = scope.join('::')
      return unless %i[required optional].include?(node.children.first.children.last) &&
                    header_table.retrieve_class(klass).superklass == 'Mutations::Command'

      mutations = node.children.last.type == :send ? [node.children.last] : node.children.last.children # rubocop:disable Metrics/LineLength
      mutations.each do |mutation|
        store_param_type(mutation, header_table, scope)
      end
    end

    def to_namespace(node)
      return [] unless node.respond_to?(:children)

      _receiver, name = node.children
      [to_namespace(node.children.first), name].flatten.compact
    end

    def store_param_type(param, header_table, scope)
      _, type, identifier = param.children
      header_table.store_mutation("#{scope.join('::')}.#{identifier.children.last}", type)
    end
  end
end
