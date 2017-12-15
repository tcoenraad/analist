# frozen_string_literal: true

module Analist
  class TypeError
    attr_reader :expected_annotation, :actual_annotation

    def initialize(node, expected_annotation:, actual_annotation:)
      @node = node
      @expected_annotation = expected_annotation
      @actual_annotation = actual_annotation
    end

    def annotation_difference
      diff = []
      %i[receiver_type return_type args_types].each do |type|
        expected = expected_annotation.send(type)
        actual = actual_annotation.send(type)
        humanized_type = type.to_s.humanize(capitalize: false)
        if expected != actual
          diff << "expected `#{expected.inspect}` #{humanized_type}, actual `#{actual.inspect}`"
        end
      end
      diff
    end

    def to_s
      "#{Analist::FileFinder.relative_path(@node.filename)}:#{@node.loc.line} TypeError: "\
        "#{annotation_difference.join(', ')}"
    end
  end

  class ArgumentError
    attr_reader :expected_number_of_args, :actual_number_of_args

    def initialize(node, expected_number_of_args:, actual_number_of_args:)
      @node = node
      @expected_number_of_args = expected_number_of_args
      @actual_number_of_args = actual_number_of_args
    end

    def to_s
      _receiver, method, = @node.children
      "#{Analist::FileFinder.relative_path(@node.filename)}:#{@node.loc.line} ArgumentError, "\
        "`#{method}` expected #{@expected_number_of_args}, actual: #{@actual_number_of_args}"
    end
  end
end
