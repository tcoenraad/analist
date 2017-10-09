# frozen_string_literal: true

require 'analist/version'
require 'analist/annotated_node'
require 'analist/annotator'
require 'analist/checker'
require 'analist/sql/schema'

module Analist
  module_function

  def analyze(node, schema_filename = nil)
    schema = Analist::SQL::Schema.read_from_file(schema_filename) if schema_filename
    annotated_node = Analist::Annotator.annotate(node, schema)
    Analist::Checker.check(annotated_node)
  end
end
