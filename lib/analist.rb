# frozen_string_literal: true

require 'parser/ruby24'
require 'pry'

require 'analist/version'

require 'analist/annotated_node'
require 'analist/annotator'
require 'analist/checker'
require 'analist/config'
require 'analist/explorer'
require 'analist/headerizer'
require 'analist/resolve_lookup'
require 'analist/ruby_extractor'
require 'analist/sql/schema'

module Analist
  module_function

  def analyze(files, schema_filename: nil, global_types: {})
    schema = Analist::SQL::Schema.read_from_file(schema_filename) if schema_filename

    nodes = files.map { |filename| Analist::Explorer.explore(filename) }
    headers = Analist::Headerizer.headerize(nodes)

    symbol_table = SymbolTable.new
    global_types.each do |identifier, type|
      symbol_table.store(identifier, Analist::Annotation.new(nil, [], type))
    end

    nodes.map { |node| analyze_node(node, schema, headers, symbol_table) }
  end

  def analyze_node(node, schema, headers, symbol_table)
    resources = { schema: schema, headers: headers, symbol_table: symbol_table }
    annotated_node = Analist::Annotator.annotate(node, resources)
    Analist::Checker.check(annotated_node)
  end

  def parse(string)
    Parser::Ruby24.parse(string)
  end

  def parse_file(file)
    parse(IO.read(file))
  end
end
