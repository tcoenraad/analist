# frozen_string_literal: true

require 'active_support/inflector'

require_relative '../ast/const_node'

module Analist
  module Analyze
    class SendResolver
      def initialize(send_node, schema, var_to_type_map: {}, context: [])
        @send_node = send_node
        @schema = schema
        @var_to_type_map = var_to_type_map
        @context = context
      end

      def type_error?
        return unless @send_node.receiver
        return coerces? unless @send_node.receiver.type == :send

        self.class.new(Analist::AST::SendNode.new(@send_node.receiver), @schema,
                       var_to_type_map: @var_to_type_map,
                       context: @context + [@send_node]).type_error?
      end

      private

      def coerces?
        context = @context.any? ? @context : [@send_node]
        Analist::Analyze::Coerce.new(
          operator: context.first.method,
          type: resolve_type,
          args: context.first.args,
          var_to_type_map: @var_to_type_map
        ).error?
      end

      def resolve_type # rubocop:disable Metrics/AbcSize
        return @send_node.receiver.type if
          Constants.primitive_types.include?(@send_node.receiver.type)

        if transformed_type == :object # rubocop:disable Style/GuardClause
          @schema[@send_node.receiver.children.last.to_s.downcase.pluralize]
            .find_type_for(@context.last.method.to_s)
        end
      end

      def transformed_type
        call_chain.inject(:collection) do |transformed_type, method|
          Constants.ar_transform_map[transformed_type][method]
        end
      end

      def call_chain
        [@send_node.method] + @context.drop(2).map(&:method)
      end
    end
  end
end
