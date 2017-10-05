# frozen_string_literal: true

RSpec.describe Analist::Annotator do
  let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

  describe '#annotate' do
    context 'when parsing a simple calculation' do
      subject(:annotation_node) { described_class.annotate(CommonHelpers.parse('1 + 1')) }

      it { expect(annotation_node.annotation).to eq [Integer, [Integer], Integer] }
    end

    context 'when parsing a simple method call' do
      subject(:annotation_node) { described_class.annotate(CommonHelpers.parse('"word".reverse')) }

      it { expect(annotation_node.annotation).to eq [String, [], String] }
    end

    context 'when parsing a chained method call' do
      subject(:annotation_node) do
        described_class.annotate(CommonHelpers.parse('"word".reverse.upcase'))
      end

      it { expect(annotation_node).to be_instance_of Analist::AnnotatedNode }
      it { expect(annotation_node.annotation).to eq [String, [], String] }
      it { expect(annotation_node.children.first.annotation).to eq [String, [], String] }
    end

    context 'when parsing an Active Record object its property' do
      let(:annotation_node) do
        described_class.annotate(CommonHelpers.parse('User.first.id'), schema)
      end
      let(:annotation_node2) do
        described_class.annotate(CommonHelpers.parse('User.first.first_name'), schema)
      end

      it { expect(annotation_node.annotation).to eq [{ type: :User, on: :instance }, [], Integer] }
      it { expect(annotation_node2.annotation).to eq [{ type: :User, on: :instance }, [], String] }
    end

    context 'when parsing an Active Record collection' do
      let(:annotation_node) do
        described_class.annotate(CommonHelpers.parse('User.all'), schema)
      end

      it do
        expect(annotation_node.annotation).to eq [
          { type: :User, on: :collection }, [],
          { type: :User, on: :collection }
        ]
      end
    end

    context 'when duck typing, e.g. `reverse`' do
      let(:annotation_node) { described_class.annotate(CommonHelpers.parse('"word".reverse')) }
      let(:annotation_node2) { described_class.annotate(CommonHelpers.parse('[1, 2, 3].reverse')) }

      it { expect(annotation_node.annotation).to eq [String, [], String] }
      it { expect(annotation_node2.annotation).to eq [Array, [], Array] }
    end

    context 'when annotating nested statements' do
      subject(:annotation_node) { described_class.annotate(CommonHelpers.parse('[1] + ["a"]')) }

      it { expect(annotation_node.annotation).to eq [Array, [Array], Array] }
      it { expect(annotation_node.children.first.annotation).to eq [nil, [], Array] }
      it do
        expect(annotation_node.children.first.children.first.annotation).to eq [nil, [], Integer]
      end
    end
  end
end
