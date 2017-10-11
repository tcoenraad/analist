# frozen_string_literal: true

RSpec.describe Analist::Checker do
  subject(:checker) { described_class.check(annotated_node) }

  let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

  let(:expected_annotation) { checker.first.expected_annotation }
  let(:actual_annotation) { checker.first.actual_annotation }

  describe '#check' do
    context 'when parsing a simple calculation' do
      let(:annotated_node) { Analist::Annotator.annotate(CommonHelpers.parse('1 + 1')) }

      it { expect(checker).to eq [] }
    end

    context 'when parsing a simple statement' do
      let(:annotated_node) { Analist::Annotator.annotate(CommonHelpers.parse('[1]')) }

      it { expect(checker).to eq [] }
    end

    context 'when parsing a nested calculation statement' do
      let(:annotated_node) { Analist::Annotator.annotate(CommonHelpers.parse('[1 + 1]')) }

      it { expect(checker).to eq [] }
    end

    context 'when parsing an invalid method call' do
      let(:annotated_node) { Analist::Annotator.annotate(CommonHelpers.parse('"a".reverse(1)')) }

      it { expect(checker.first).to be_kind_of Analist::ArgumentError }
      it { expect(checker.first.expected_number_of_args).to eq 0 }
      it { expect(checker.first.actual_number_of_args).to eq 1 }
    end

    context 'when parsing an invalid simple coercion' do
      let(:annotated_node) { Analist::Annotator.annotate(CommonHelpers.parse('1 + "a"')) }

      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end

    context 'when parsing an invalid Active Record property coercion' do
      let(:annotated_node) do
        Analist::Annotator.annotate(CommonHelpers.parse('User.first.id + "a"'), schema)
      end

      it { expect(checker.first).to be_kind_of Analist::TypeError }
      it { expect(expected_annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
      it { expect(actual_annotation).to eq Analist::Annotation.new(Integer, [String], Integer) }
    end
  end
end
