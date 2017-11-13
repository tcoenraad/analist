# frozen_string_literal: true

require 'analist/version'

require 'analist/annotated_node'
require 'analist/annotator'
require 'analist/checker'
require 'analist/config'
require 'analist/headerizer'
require 'analist/ruby_extractor'
require 'analist/sql/schema'

module Analist
  module_function

  def analyze(files, schema_filename: nil)
    nodes = files.each_with_object({}) do |filename, h|
      h[filename] = to_ast(filename)
      h
    end
    schema = Analist::SQL::Schema.read_from_file(schema_filename) if schema_filename
    headers = Headerizer.headerize(nodes.values)

    nodes.each_with_object({}) do |(filename, node), errors|
      errors[filename] = analyze_node(node, schema, headers)
    end
  end

  def analyze_node(node, schema, headers)
    resources = { schema: schema, headers: headers }
    annotated_node = Analist::Annotator.annotate(node, resources)
    Analist::Checker.check(annotated_node)
  end

  def to_ast(file)
    Parser::Ruby24.parse(IO.read(file))
  end
end
