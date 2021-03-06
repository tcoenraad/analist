# frozen_string_literal: true

RSpec.describe Analist::Checker do
  subject(:errors) do
    described_class.check(Analist::Annotator.annotate(CommonHelpers.parse(expression), resources))
  end

  let(:resources) { { schema: schema, headers: headers, symbol_table: symbol_table } }
  let(:schema) { Analist::SQL::Schema.new  }
  let(:headers) { Analist::HeaderTable.new }
  let(:symbol_table) { Analist::SymbolTable.new }

  let(:exp_annotation) { errors.first.expected_annotation }
  let(:act_annotation) { errors.first.actual_annotation }

  describe '#check' do
    context 'when checking an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(errors).to be_empty }
    end

    context 'when checking an unknown function call with an invalid argument' do
      let(:expression) { 'JSON.parse(1 + "bla")' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: `+` expected `Integer` args, actual `String`'
        )
      end
    end

    context 'when checking an unknown property' do
      let(:expression) { 'a.unknown_property' }

      it { expect(errors).to be_empty }
    end

    context 'when checking an unknown property on a primitive type' do
      let(:expression) { '1.unknown_property' }

      it { expect(errors).to be_empty }
    end

    context 'when checking a known property on a unknown variable' do
      let(:expression) { 'error.first.to_s' }

      it { expect(errors).to be_empty }
    end

    context 'when checking a calculation on an unknown property on a Active Record object' do
      let(:expression) { 'User.first.unknown_property + 1' }

      it { expect(errors).to be_empty }
    end

    context 'when checking a simple calculation' do
      let(:expression) { '1 + 1' }

      it { expect(errors).to be_empty }
    end

    context 'when checking a simple statement' do
      let(:expression) { '[1]' }

      it { expect(errors).to be_empty }
    end

    context 'when checking a nested calculation statement' do
      let(:expression) { '[1 + 1]' }

      it { expect(errors).to be_empty }
    end

    context 'when checking a valid regex' do
      let(:expression) { '"example".gsub(/[aeiou]/, "")' }

      it { expect(errors).to be_empty }
    end

    context 'when checking an invalid regex' do
      let(:expression) { '"example".gsub(1, "")' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: `gsub` expected `Regexp,String or Regexp or String,String` '\
          'args, actual `Integer,String`'
        )
      end
    end

    context 'when checking a method call that accepts both strings and symbols' do
      context 'when string' do
        subject(:expression) { '1.respond_to?("+")' }

        it { expect(errors).to be_empty }
      end

      context 'when symbol' do
        subject(:expression) { '1.respond_to?(:+)' }

        it { expect(errors).to be_empty }
      end
    end

    context 'when checking an invalid method call' do
      let(:expression) { '"a".reverse(1)' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 ArgumentError: `reverse` expected 0 args, actual: 1'
        )
      end
    end

    context 'when checking an invalid simple coercion' do
      let(:expression) { '1 + "a"' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: `+` expected `Integer` args, actual `String`'
        )
      end
    end

    context 'with method that requires a block' do
      context 'with item' do
        let(:expression) { '[1].map { |item| item }' }

        it { expect(errors).to be_empty }
      end

      context 'without item' do
        let(:expression) { '[1].map { "string" }' }

        it { expect(errors).to be_empty }
      end
    end

    context 'with method that requires a block without one' do
      let(:expression) { '[1].map("string")' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 ArgumentError: `map` expected 0 args, actual: 1'
        )
      end
    end

    context 'when checking a method chain with block' do
      context 'with valid coercion' do
        let(:expression) { '[1,2,3].map(&:to_s).join + "1"' }

        it { expect(errors).to be_empty }
      end

      context 'with invalid coercion' do
        let(:expression) { '[1,2,3].map(&:to_s).join + 1' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: `+` expected `String` args, actual `Integer`'
          )
        end
      end
    end

    context 'with Active Record' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }
      let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

      context 'when checking an invalid Active Record property coercion' do
        let(:expression) { 'User.first.id + "a"' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: `+` expected `Integer` args, actual `String`'
          )
        end
      end

      context 'when checking a variable assignment and multiple references on an object' do
        let(:expression) { 'var = User.first ; var.id + var.full_name' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: `+` expected `Integer` args, actual `String`'
          )
        end
      end

      context 'when checking a variable assignment and multiple references on an object' do
        let(:expression) { 'var = User.first ; var.id + var.full_name' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: `+` expected `Integer` args, actual `String`'
          )
        end
      end
    end

    context 'when checking a forgotten decorator' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }
      let(:expression) { 'User.first.short_name' }

      it do
        expect(errors.first.to_s).to eq(
          "filename.rb:1 DecorateWarning: method `short_name' would exist when User is decorated"
        )
      end
    end

    context 'when checking a method with a dynamic string as return value' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/klass.rb') }
      let(:expression) { 'Klass.method_with_argument(arg) + 1' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: `+` expected `String` args, actual `Integer`'
        )
      end
    end

    context 'when checking a method that calls a method shadowing a variable' do
      let(:expression) do
        <<-HEREDOC
        class Klass
          def method_with_call
            local_assignment

            variable + 'a'
          end

          def local_assignment
            variable = 1
          end
        end
        HEREDOC
      end

      let(:headers) { Analist::Headerizer.headerize([CommonHelpers.parse(expression)]) }

      it { expect(errors).to be_empty }
    end

    context 'when type checking mutations' do
      let(:expression) do
        <<-HEREDOC
        class UpdateUser < Mutations::Command
          required do
            integer :id
          end

          def execute
            id + 'a'
          end
        end

        HEREDOC
      end

      let(:headers) { Analist::Headerizer.headerize([CommonHelpers.parse(expression)]) }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:7 TypeError: `+` expected `Integer` args, actual `String`'
        )
      end
    end
  end

  context 'when type checking an Annotation::AnyClass arg' do
    describe 'when from standard libary' do
      let(:expression) { 'include Klass' }

      it { expect(errors).to be_empty }
    end
    describe 'when from standard libary' do
      let(:expression) { 'include Klass + 3' }

      it { expect(errors).to be_empty }
    end
  end

  context 'when type checking a method with multiple accepting arg types' do
    describe 'with wrong arg type' do
      let(:expression) { '1.to_s("lorem ipsum")' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: `to_s` expected `[] or Integer` args, actual `String`'
        )
      end
    end

    describe 'with wrong arg amount' do
      let(:expression) { '1.to_s(1,2)' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 ArgumentError: `to_s` expected 0 or 1 args, actual: 2'
        )
      end
    end
  end
end
