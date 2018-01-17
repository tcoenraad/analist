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
      diffs = []
      %i[receiver_type return_type].each do |type|
        expected = expected_annotation.send(type)
        actual = actual_annotation.send(type)
        humanized_type = type.to_s.humanize(capitalize: false)
        if expected != actual
          diffs << "expected `#{expected[:type]}` #{humanized_type}, actual `#{actual[:type]}`"
        end
      end

      diffs.append(annotation_difference_on_args_types(expected_annotation.args_types,
                                                       actual_annotation.args_types))
    end

    def annotation_difference_on_args_types(expected, actual)
      return unless expected != actual

      diff = 'expected `'
      diff += if expected.is_a?(Set)
                expected.map do |set|
                  set.any? ? set.map { |at| at[:type] }.join(',') : '[]'
                end.join(' or ')
              else
                expected.map { |arg_type| arg_type[:type] }.join(',')
              end
      diff + "` args, actual `#{actual.map { |args_types| args_types[:type] }.join(',')}`"
    end

    def to_s
      _receiver, method, = @node.children

      "#{Analist::FileFinder.relative_path(@node.filename)}:#{@node.loc.line} TypeError: "\
        "`#{method}` #{annotation_difference.join(', ')}"
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
        "`#{method}` expected #{@expected_number_of_args.join(' or ')} args, "\
        "actual: #{@actual_number_of_args}"
    end
  end
end
