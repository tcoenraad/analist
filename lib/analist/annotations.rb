# frozen_string_literal: true

module Analist
  class Annotation
    attr_reader :receiver_type, :args_types, :return_type

    def initialize(receiver_type, args_types, return_type)
      @receiver_type = receiver_type.is_a?(Hash) ? receiver_type : { type: receiver_type }
      @args_types = args_types
      @return_type = return_type.is_a?(Hash) ? return_type : { type: return_type }
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      [receiver_type, args_types, return_type] ==
        [other.receiver_type, other.args_types, other.return_type]
    end

    def to_s
      [receiver_type, args_types, return_type].to_s
    end
  end

  class AnnotationTypeUnknown; end

  module Annotations
    module_function

    def send_annotations # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      {
        :+ => lambda do |annotated_children|
          {
            Integer => Annotation.new(Integer, [Integer], Integer),
            String => Annotation.new(String, [String], String),
            Array => Annotation.new(Array, [Array], Array)
          }[annotated_children.first.annotation.return_type[:type]]
        end,
        upcase: ->(_) { Annotation.new(String, [], String) },
        reverse: lambda do |annotated_children|
          {
            String => Annotation.new(String, [], String),
            Array => Annotation.new(Array, [], Array)
          }[annotated_children.first.annotation.return_type[:type]]
        end,
        all: lambda do |annotated_children|
          Annotation.new(
            { type: annotated_children.first.annotation.return_type[:type], on: :collection },
            [],
            type: annotated_children.first.annotation.return_type[:type], on: :collection
          )
        end,
        first: lambda do |annotated_children|
          Annotation.new(
            { type: annotated_children.first.annotation.return_type[:type], on: :collection },
            [],
            type: annotated_children.first.annotation.return_type[:type], on: :instance
          )
        end
      }
    end

    def primitive_annotations
      {
        int: ->(_) { Annotation.new(nil, [], Integer) },
        str: ->(_) { Annotation.new(nil, [], String) },
        const: ->(node) { Annotation.new(nil, [], type: node.children.last, on: :collection) }
      }
    end
  end
end
