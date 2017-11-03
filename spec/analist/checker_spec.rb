# frozen_string_literal: true

RSpec.describe Analist::Checker do
  subject(:errors) do
    described_class.check(Analist::Annotator.annotate(CommonHelpers.parse(expression), resources))
  end

  let(:resources) do
    { schema: Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql'),
      headers: headers }
  end
  let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }

  let(:expected_annotation) { errors.first.expected_annotation }
  let(:actual_annotation) { errors.first.actual_annotation }

  describe '#check' do
    context 'when checking an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(errors).to eq [] }
    end

    context 'when checking an unknown property' do
      let(:expression) { 'a.unknown_property' }

      it { expect(errors).to eq [] }
    end

    context 'when checking an unknown property on a primitive type' do
      let(:expression) { '1.unknown_property' }

      it { expect(errors).to eq [] }
    end

    context 'when checking a calculation on an unknown property on a Active Record object' do
      let(:expression) { 'User.first.unknown_property + 1' }

      it { expect(errors).to eq [] }
    end

    context 'when checking a simple calculation' do
      let(:expression) { '1 + 1' }

      it { expect(errors).to eq [] }
    end

    context 'when checking a simple statement' do
      let(:expression) { '[1]' }

      it { expect(errors).to eq [] }
    end

    context 'when checking a nested calculation statement' do
      let(:expression) { '[1 + 1]' }

      it { expect(errors).to eq [] }
    end

    context 'when checking an invalid method call' do
      let(:expression) { '"a".reverse(1)' }

      it { expect(errors.first).to be_kind_of Analist::ArgumentError }
      it { expect(errors.first.expected_number_of_args).to eq 0 }
      it { expect(errors.first.actual_number_of_args).to eq 1 }
    end

    context 'when checking an invalid simple coercion' do
      let(:expression) { '1 + "a"' }

      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end

    context 'when checking an invalid Active Record property coercion' do
      let(:expression) { 'User.first.id + "a"' }

      it { expect(errors.first).to be_kind_of Analist::TypeError }
      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end

    context 'when checking a variable assignment and multiple references on an object' do
      let(:expression) { 'var = User.first ; var.id + var.full_name' }

      it { expect(errors.first).to be_kind_of Analist::TypeError }
      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end
  end
end
