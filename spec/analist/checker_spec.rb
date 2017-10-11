# frozen_string_literal: true

RSpec.describe Analist::Checker do
  subject(:checker) do
    described_class.check(Analist::Annotator.annotate(CommonHelpers.parse(expression), schema))
  end

  let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

  let(:expected_annotation) { checker.first.expected_annotation }
  let(:actual_annotation) { checker.first.actual_annotation }

  describe '#check' do
    context 'when parsing an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(checker).to eq [] }
    end

    context 'when parsing an unknown property' do
      let(:expression) { 'a.unknown_property' }

      it { expect(checker).to eq [] }
    end

    context 'when parsing an unknown property on a primitive type' do
      let(:expression) { '1.unknown_property' }

      it { expect(checker).to eq [] }
    end

    context 'when parsing a simple calculation' do
      let(:expression) { '1 + 1' }

      it { expect(checker).to eq [] }
    end

    context 'when parsing a simple statement' do
      let(:expression) { '[1]' }

      it { expect(checker).to eq [] }
    end

    context 'when parsing a nested calculation statement' do
      let(:expression) { '[1 + 1]' }

      it { expect(checker).to eq [] }
    end

    context 'when parsing an invalid method call' do
      let(:expression) { '"a".reverse(1)' }

      it { expect(checker.first).to be_kind_of Analist::ArgumentError }
      it { expect(checker.first.expected_number_of_args).to eq 0 }
      it { expect(checker.first.actual_number_of_args).to eq 1 }
    end

    context 'when parsing an invalid simple coercion' do
      let(:expression) { '1 + "a"' }

      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end

    context 'when parsing an invalid Active Record property coercion' do
      let(:expression) { 'User.first.id + "a"' }

      it { expect(checker.first).to be_kind_of Analist::TypeError }
      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end
  end
end
