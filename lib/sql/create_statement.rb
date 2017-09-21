# frozen_string_literal: true

module SQL
  class CreateStatement
    def initialize(tree)
      @tree = tree
    end

    def table_name
      @tree['relation']['RangeVar']['relname']
    end

    def columns
      column_defs.each_with_object({}) do |s, h|
        h[s['ColumnDef']['colname']] = s['ColumnDef']['typeName']['TypeName']['names'].map do |type|
          type['String']['str']
        end
        h
      end
    end

    private

    def column_defs
      @tree['tableElts'].select { |s| s.key?('ColumnDef') }
    end
  end
end
