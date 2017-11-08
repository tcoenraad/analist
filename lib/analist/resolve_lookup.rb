# frozen_string_literal: true

module Analist
  module ResolveLookup
    class Headers
      def initialize(annotated_children, resources)
        @headers = resources[:headers]
        @symbol_table = resources[:symbol_table]

        @receiver, @method = annotated_children
      end

      def return_type
        return unless @headers

        Analist::Annotator.annotate(last_statement).annotation.return_type if last_statement
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
        @symbol_table.current_klass_name
      end

      def last_statement
        @headers.retrieve_method(method_name, klass_name)&.children&.last
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
  end
end