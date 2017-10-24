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

    def find_headers(node, header_table, scope: []) # rubocop:disable Metrics/AbcSize
      return unless node

      case node.type
      when :begin
        node.children.map { |n| find_headers(n, header_table, scope: scope) }
      when :class
        klass, superklass, body = node.children
        header_table.store_class(to_namespace(klass),
                                 scope: scope, superklass: to_namespace(superklass))
        find_headers(body, header_table, scope: scope + [to_namespace(klass)])
      when :def
        method, = node.children
        header_table.store_method(method, scope, node)
      when :module
        namespace, body = node.children
        find_headers(body, header_table, scope: scope + [to_namespace(namespace)])
      end
    end

    def to_namespace(node)
      return unless node.respond_to?(:children)

      _receiver, name = node.children
      [to_namespace(node.children.first), name].flatten.compact
    end
  end
end
