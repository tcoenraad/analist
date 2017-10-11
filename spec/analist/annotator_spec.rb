# frozen_string_literal: true

RSpec.describe Analist::Annotator do
  let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

  describe '#annotate' do
    subject(:annotation) { annotated_node.annotation }

    context 'when parsing an unknown property' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('a.unknown_property'))
      end

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when parsing an unknown property on a primitive type' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('1.unknown_property'))
      end

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when parsing a simple calculation' do
      subject(:annotated_node) { described_class.annotate(CommonHelpers.parse('1 + 1')) }

      it { expect(annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
    end

    context 'when parsing a simple method call' do
      subject(:annotated_node) { described_class.annotate(CommonHelpers.parse('"word".reverse')) }

      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
    end

    context 'when parsing a chained method call' do
      subject(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('"word".reverse.upcase'))
      end

      it { expect(annotated_node).to be_instance_of Analist::AnnotatedNode }
      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
      it do
        expect(annotated_node.children.first.annotation).to eq(
          Analist::Annotation.new(String, [], String)
        )
      end
    end

    context 'when parsing a known property on a Active Record object' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('User.first.id'), schema)
      end
      let(:annotated_node2) do
        described_class.annotate(CommonHelpers.parse('User.first.first_name'), schema)
      end

      it { expect(annotation).to eq Analist::Annotation.new(:User, [], Integer) }
      it do
        expect(annotated_node2.annotation).to eq(
          Analist::Annotation.new(:User, [], String)
        )
      end
    end

    context 'when parsing an unknown property on a Active Record object' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('User.first.unknown_property'), schema)
      end

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
      it do
        expect(annotated_node.children.first.annotation).to eq(
          Analist::Annotation.new({ type: :User, on: :collection }, [], type: :User, on: :instance)
        )
      end
      it do
        expect(annotated_node.children.first.children.first.annotation).to eq(
          Analist::Annotation.new({ type: nil }, [], type: :User, on: :collection)
        )
      end
    end

    context 'when parsing an Active Record collection' do
      let(:annotated_node) do
        described_class.annotate(CommonHelpers.parse('User.all'), schema)
      end

      it do
        expect(annotated_node.annotation).to eq Analist::Annotation.new(
          { type: :User, on: :collection }, [], type: :User, on: :collection
        )
      end
    end

    context 'when duck typing, e.g. `reverse`' do
      let(:annotated_node) { described_class.annotate(CommonHelpers.parse('"word".reverse')) }
      let(:annotated_node2) { described_class.annotate(CommonHelpers.parse('[1, 2, 3].reverse')) }

      it { expect(annotated_node.annotation).to eq Analist::Annotation.new(String, [], String) }
      it { expect(annotated_node2.annotation).to eq Analist::Annotation.new(Array, [], Array) }
    end

    context 'when annotating nested statements' do
      subject(:annotated_node) { described_class.annotate(CommonHelpers.parse('[1] + ["a"]')) }

      it { expect(annotated_node.annotation).to eq Analist::Annotation.new(Array, [Array], Array) }
      it do
        expect(annotated_node.children.first.annotation).to eq(
          Analist::Annotation.new(nil, [], Array)
        )
      end
      it do
        expect(annotated_node.children[0].children.first.annotation).to eq(
          Analist::Annotation.new(nil, [], Integer)
        )
      end
      it do
        expect(annotated_node.children[2].children.first.annotation).to eq(
          Analist::Annotation.new(nil, [], String)
        )
      end
    end
  end
end
