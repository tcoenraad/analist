# frozen_string_literal: true

require 'parser/ruby24'
require 'pry'

require 'analist/version'

require 'analist/annotated_node'
require 'analist/annotator'
require 'analist/checker'
require 'analist/config'
require 'analist/explorer'
require 'analist/file_finder'
require 'analist/headerizer'
require 'analist/resolve_lookup'
require 'analist/ruby_extractor'
require 'analist/sql/schema'

module Analist
  module_function

  def analyze(files, schema_filename: nil, global_types: {})
    schema = Analist::SQL::Schema.read_from_file(schema_filename) if File.exist?(schema_filename)

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
    buffer = Parser::Source::Buffer.new('(string)')
    buffer.source = string

    node = parser.parse(buffer)

    @diagnostics.each do |diagnostic|
      STDERR.puts "(string):#{diagnostic.location.line - 1} SyntaxError: #{diagnostic.message}"
    end
    exit 1 if @diagnostics.any?

    node
  end

  def parse_file(file)
    parse(IO.read(file, encoding: 'UTF-8'))
  end

  def parser
    @diagnostics = []
    Parser::Ruby24.new.tap do |parser|
      parser.diagnostics.ignore_warnings = false
      parser.diagnostics.consumer = lambda do |diagnostic|
        @diagnostics << diagnostic
      end
    end
  end
end
