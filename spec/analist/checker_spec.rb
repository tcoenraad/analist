# frozen_string_literal: true

RSpec.describe Analist::Checker do
  subject(:errors) do
    described_class.check(Analist::Annotator.annotate(CommonHelpers.parse(expression), resources))
  end

  describe '#check' do
    let(:resources) { { schema: schema, headers: headers, symbol_table: symbol_table } }
    let(:schema) { Analist::SQL::Schema.new  }
    let(:headers) { Analist::HeaderTable.new }
    let(:symbol_table) { Analist::SymbolTable.new }

    let(:exp_annotation) { errors.first.expected_annotation }
    let(:act_annotation) { errors.first.actual_annotation }

    context 'when checking an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(errors).to be_empty }
    end

    context 'when annotating an unknown function call' do
      let(:expression) { 'JSON.parse(1 + "bla")' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: expected `[Integer]` args types, actual `[String]`'
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

    context 'when checking an invalid method call' do
      let(:expression) { '"a".reverse(1)' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 ArgumentError, expected 0, actual: 1'
        )
      end
    end

    context 'when checking an invalid simple coercion' do
      let(:expression) { '1 + "a"' }

      it do
        expect(errors.first.to_s).to eq(
          'filename.rb:1 TypeError: expected `[Integer]` args types, actual `[String]`'
        )
      end
    end

    context 'with Active Record' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }
      let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

      context 'when checking an invalid Active Record property coercion' do
        let(:expression) { 'User.first.id + "a"' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: expected `[Integer]` args types, actual `[String]`'
          )
        end
      end

      context 'when checking a variable assignment and multiple references on an object' do
        let(:expression) { 'var = User.first ; var.id + var.full_name' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: expected `[Integer]` args types, actual `[String]`'
          )
        end
      end

      context 'when checking a variable assignment and multiple references on an object' do
        let(:expression) { 'var = User.first ; var.id + var.full_name' }

        it do
          expect(errors.first.to_s).to eq(
            'filename.rb:1 TypeError: expected `[Integer]` args types, actual `[String]`'
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
      let(:expression) { 'Klass.method_with_argument(arg)' }

      it { expect(errors).to be_empty }
    end
  end
end
