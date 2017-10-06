# frozen_string_literal: true

RSpec.describe Analist::Annotator do
  let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

  describe '#annotate' do
    context 'when parsing a simple calculation' do
      subject(:annotated_node) { described_class.annotate(CommonHelpers.parse('1 + 1')) }

      it { expect(annotated_node.annotation).to eq [Integer, [Integer], Integer] }
    end

    context 'when parsing a simple method call' do
      subject(:annotated_node) { described_class.annotate(CommonHelpers.parse('"word".reverse')) }

      it { expect(annotated_node.annotation).to eq [String, [], String] }
    end

    context 'when parsing a chained method call' do
      subject(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('"word".reverse.upcase'))
      end

      it { expect(annotated_node).to be_instance_of Analist::AnnotatedNode }
      it { expect(annotated_node.annotation).to eq [String, [], String] }
      it { expect(annotated_node.children.first.annotation).to eq [String, [], String] }
    end

    context 'when parsing an Active Record object its property' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('User.first.id'), schema)
      end
      let(:annotated_node2) do
        described_class.annotate(CommonHelpers.parse('User.first.first_name'), schema)
      end

      it { expect(annotated_node.annotation).to eq [{ type: :User, on: :instance }, [], Integer] }
      it { expect(annotated_node2.annotation).to eq [{ type: :User, on: :instance }, [], String] }
    end

    context 'when parsing an Active Record collection' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('User.all'), schema)
      end

      it do
        expect(annotated_node.annotation).to eq [
          { type: :User, on: :collection }, [],
          { type: :User, on: :collection }
        ]
      end
    end

    context 'when duck typing, e.g. `reverse`' do
      let(:annotated_node) { described_class.annotate(CommonHelpers.parse('"word".reverse')) }
      let(:annotated_node2) { described_class.annotate(CommonHelpers.parse('[1, 2, 3].reverse')) }

      it { expect(annotated_node.annotation).to eq [String, [], String] }
      it { expect(annotated_node2.annotation).to eq [Array, [], Array] }
    end

    context 'when annotating nested statements' do
      subject(:annotated_node) { described_class.annotate(CommonHelpers.parse('[1] + ["a"]')) }

      it { expect(annotated_node.annotation).to eq [Array, [Array], Array] }
      it { expect(annotated_node.children.first.annotation).to eq [nil, [], Array] }
      it do
        expect(annotated_node.children[0].children.first.annotation).to eq [nil, [], Integer]
      end
      it do
        expect(annotated_node.children[2].children.first.annotation).to eq [nil, [], String]
      end
    end
  end
end
