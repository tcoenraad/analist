# frozen_string_literal: true

require 'analist/annotated_node'
require 'analist/annotator'
require 'analist/checker'
require 'analist/sql/schema'

module Analist
  module Analyzer
    extend Annotator
    extend Checker

    module_function

    def analyze(node, schema_filename: nil)
      schema = Analist::SQL::Schema.read_from_file(schema_filename) if schema_filename
      annotated_node = annotate(node, schema)
      check(annotated_node)
    end
  end
end
