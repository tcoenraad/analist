# frozen_string_literal: true

require 'pry'

module Analist
  module ResolveLookup
    class Headers
      def initialize(annotated_children, resources)
        @resources = resources
        @headers = resources[:headers]
        @symbol_table = resources[:symbol_table]

        @receiver, @method = annotated_children
      end

      def return_type # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        return unless @headers
        return mutation_type if @resources[:symbol_table].scope.last == :execute
        return unless (last_statement =
                         @headers.retrieve_method(method_name, klass_name)&.children&.last)
        lookup_chain = @resources.fetch(:lookup_chain, [])

        return if lookup_chain.include?(@method)

        @resources[:lookup_chain] = lookup_chain + [@method]
        @resources[:symbol_table].enter_scope
        return_type = Analist::Annotator.annotate(last_statement, @resources).annotation.return_type
        @resources[:symbol_table].exit_scope
        @resources.delete(:lookup_chain)
        return_type
      end

      def klass_method?
        @symbol_table.current_scope_klass? ||
          @receiver&.annotation&.return_type&.fetch(:on, nil) == :collection
      end

      def method_name
        return :"self.#{@method}" if klass_method?
        @method
      end

      def klass_name
        return @receiver.annotation.return_type[:type].to_s if @receiver
        @symbol_table.scope[0..-2].join('::')
      end

      def mutation_type
        identifier = "#{@resources[:symbol_table].scope[0...-1].join('::')}.#{@method}"
        @resources[:headers].retrieve_mutation(identifier)
      end
    end

    class Schema
      def initialize(annotated_children, resources)
        @schema = resources[:schema]
        @receiver, @method = annotated_children
      end

      def return_type
        return unless @schema
        return unless @receiver
        return unless @receiver.annotation.return_type[:on] == :instance
        return unless @schema.table_exists?(table_name)

        @schema[table_name].lookup_type_for_method(@method.to_s)
      end

      def table_name
        @receiver.annotation.return_type[:type].to_s.downcase.pluralize
      end
    end

    class Hint
      class Decorate; end

      def initialize(annotated_children, resources)
        @headers = resources[:headers]
        @symbol_table = resources[:symbol_table]

        @receiver, @method = annotated_children
      end

      def hint
        return Decorate if decorate?
      end

      private

      def decorate?
        return unless @receiver
        return unless @headers

        klass = "#{@receiver.annotation.return_type[:type]}Decorator"
        return unless @headers.retrieve_method(@method, klass)
        true
      end
    end
  end
end
