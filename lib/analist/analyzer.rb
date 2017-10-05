# frozen_string_literal: true

require_relative './annotated_node'
require_relative './annotator'
require_relative './checker'
require_relative './sql/schema'

module Analist
  module Analyzer
    extend Annotator
    extend Checker

    module_function

    def analyze(node, filename = nil)
      schema = Analist::SQL::Schema.read_from_file(filename) if filename
      annotated_node = annotate(node, schema)
      check(annotated_node)
    end
  end
end
