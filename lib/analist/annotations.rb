# frozen_string_literal: true

module Analist
  module Annotations
    module_function

    def send_annotations # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      {
        :+ => lambda do |annotated_children|
          {
            Integer => [Integer, [Integer], Integer],
            String => [String, [String], String],
            Array => [Array, [Array], Array]
          }[annotated_children.first.annotation.last]
        end,
        upcase: ->(_) { [String, [], String] },
        reverse: lambda do |annotated_children|
          {
            String => [String, [], String],
            Array => [Array, [], Array]
          }[annotated_children.first.annotation.last]
        end,
        all: lambda do |annotated_children|
          [
            { type: annotated_children.first.annotation.last[:type], on: :collection },
            [],
            { type: annotated_children.first.annotation.last[:type], on: :collection }
          ]
        end,
        first: lambda do |annotated_children|
          [
            { type: annotated_children.first.annotation.last[:type], on: :collection },
            [],
            { type: annotated_children.first.annotation.last[:type], on: :instance }
          ]
        end
      }
    end

    def primitive_annotations
      {
        int: ->(_) { [nil, [], Integer] },
        str: ->(_) { [nil, [], String] },
        const: ->(node) { [nil, [], type: node.children.last, on: :collection] }
      }
    end
  end
end
