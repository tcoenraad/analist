# frozen_string_literal: true

module Analist
  class Annotation
    attr_reader :receiver_type, :args_types, :return_type, :hint

    def initialize(receiver_type, args_types, return_type, hint: nil)
      @receiver_type = receiver_type.is_a?(Hash) ? receiver_type : { type: receiver_type }
      @args_types = args_types
      @return_type = return_type.is_a?(Hash) ? return_type : { type: return_type }
      @hint = hint
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

    def send_annotations # rubocop:disable Metrics/MethodLength
      {
        :+ => lambda do |receiver_return_type|
          {
            Integer => Annotation.new(Integer, [Integer], Integer),
            String => Annotation.new(String, [String], String),
            Array => Annotation.new(Array, [Array], Array)
          }[receiver_return_type]
        end,
        all: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type, on: :collection },
            [],
            type: receiver_return_type, on: :collection
          )
        end,
        first: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type, on: :collection },
            [],
            type: receiver_return_type, on: :instance
          )
        end,
        new: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type, on: :collection },
            [],
            type: receiver_return_type, on: :instance
          )
        end,
        reverse: lambda do |receiver_return_type|
          {
            String => Annotation.new(String, [], String),
            Array => Annotation.new(Array, [], Array)
          }[receiver_return_type]
        end,
        upcase: ->(_) { Annotation.new(String, [], String) }
      }
    end

    def primitive_annotations
      {
        dstr: ->(_) { Annotation.new(nil, [], String) },
        int: ->(_) { Annotation.new(nil, [], Integer) },
        str: ->(_) { Annotation.new(nil, [], String) },
        const: ->(node) { Annotation.new(nil, [], type: node.children.last, on: :collection) }
      }
    end
  end
end
