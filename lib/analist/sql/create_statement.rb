# frozen_string_literal: true

module Analist
  module SQL
    class CreateStatement
      def initialize(tree)
        @tree = tree
      end

      def table_name
        @tree['relation']['RangeVar']['relname']
      end

      def columns
        @columns ||= column_defs.each_with_object({}) do |s, h|
          h[s['ColumnDef']['colname']] =
            s['ColumnDef']['typeName']['TypeName']['names'].map do |type|
              type['String']['str']
            end
          h
        end
      end

      def lookup_type_for_method(column)
        self.class.sql_type_to_ast_type_map[columns[column]&.last]
      end

      def self.sql_type_to_ast_type_map
        {
          'int4' => Integer,
          'int8' => Integer,
          'varchar' => String
        }
      end

      private

      def column_defs
        @tree['tableElts'].select { |s| s.key?('ColumnDef') }
      end
    end
  end
end
