# frozen_string_literal: true

require 'pg_query'

require_relative './create_statement'

module Analist
  module SQL
    class Schema
      extend Forwardable

      attr_reader :schema

      def_delegators :schema, :table_name, :columns, :find_type_for, :[]

      def initialize(schema)
        @schema = schema
      end

      def table_exists?(table_name)
        table_names.include?(table_name)
      end

      def table_names
        schema.keys
      end

      def self.read_from_file(filename)
        tree = parse_sql(filename)
        new(create_statements(tree))
      end

      def self.parse_sql(filename)
        PgQuery.parse(File.read(filename)).tree
      end

      def self.create_statements(tree)
        tree.select { |t| t.key?('CreateStmt') }.each_with_object({}) do |t, h|
          create_statement = SQL::CreateStatement.new(t['CreateStmt'])
          h[create_statement.table_name] = create_statement
          h
        end
      end
    end
  end
end
