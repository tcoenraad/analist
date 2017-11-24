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

      attrs = %i[receiver_type args_types return_type]
      attrs.all? do |attr|
        send(attr) == other.send(attr)
      end
    end

    def to_s
      [receiver_type, args_types, return_type].to_s
    end
  end

  class AnnotationTypeUnknown; end
  class AnyArgs; end

  module Annotations
    module_function

    def send_annotations # rubocop:disable Metrics/MethodLength
      {
        :+ => lambda do |receiver_return_type|
          {
            Integer => Annotation.new(Integer, [Integer], Integer),
            String => Annotation.new(String, [String], String),
            Array => Annotation.new(Array, [Array], Array)
          }[receiver_return_type[:type]]
        end,
        all: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type[:type], on: :collection },
            [],
            type: receiver_return_type[:type], on: :collection
          )
        end,
        decorate: lambda do |receiver_return_type|
          Annotation.new(
            receiver_return_type,
            [],
            type: :"#{receiver_return_type[:type]}Decorator", on: receiver_return_type[:on]
          )
        end,
        first: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type[:type], on: :collection },
            [],
            type: receiver_return_type[:type], on: :instance
          )
        end,
        new: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type[:type], on: :collection },
            [Analist::AnyArgs],
            type: receiver_return_type[:type], on: :instance
          )
        end,
        reverse: lambda do |receiver_return_type|
          {
            String => Annotation.new(String, [], String),
            Array => Annotation.new(Array, [], Array)
          }[receiver_return_type[:type]]
        end,
        upcase: ->(_) { Annotation.new(String, [], String) }
      }
    end

    def primitive_annotations
      {
        const: ->(node) { Annotation.new(nil, [], type: node.children.last, on: :collection) },
        dstr: ->(_) { Annotation.new(nil, [], String) },
        int: ->(_) { Annotation.new(nil, [], Integer) },
        str: ->(_) { Annotation.new(nil, [], String) },
        sym: ->(_) { Annotation.new(nil, [], Symbol) }
      }
    end
  end
end
