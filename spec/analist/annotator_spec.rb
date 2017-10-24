# frozen_string_literal: true

RSpec.describe Analist::Annotator do
  let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

  describe '#annotate' do
    subject(:annotation) { annotated_node.annotation }

    let(:annotated_node) { described_class.annotate(CommonHelpers.parse(expression), schema) }

    context 'when parsing an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when parsing an unknown property on a variable' do
      let(:expression) { 'a.unknown_property' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when parsing an unknown property on a primitive type' do
      let(:expression) { '1.unknown_property' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when parsing an unknown property on a Active Record object' do
      let(:expression) { 'User.first.unknown_property' }

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

    context 'when parsing a calculation on an unknown property on a Active Record object' do
      let(:expression) { 'User.first.unknown_property + 1' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when parsing a simple calculation' do
      subject(:expression) { '1 + 1' }

      it { expect(annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
    end

    context 'when parsing a simple method call' do
      subject(:expression) { '"word".reverse' }

      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
    end

    context 'when parsing a chained method call' do
      subject(:expression) { '"word".reverse.upcase' }

      it { expect(annotated_node).to be_instance_of Analist::AnnotatedNode }
      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
      it do
        expect(annotated_node.children.first.annotation).to eq(
          Analist::Annotation.new(String, [], String)
        )
      end
    end

    context 'when parsing a known property on a Active Record object' do
      let(:expression) { 'User.first.id' }

      it do
        expect(annotation).to eq(
          Analist::Annotation.new({ type: :User, on: :instance }, [], Integer)
        )
      end
    end

    context 'when parsing an Active Record collection' do
      let(:expression) { 'User.all' }

      it do
        expect(annotation).to eq Analist::Annotation.new(
          { type: :User, on: :collection }, [], type: :User, on: :collection
        )
      end
    end

    context 'when duck typing, e.g. for `reverse`' do
      let(:expression) { '"word".reverse' }
      let(:annotated_node2) { described_class.annotate(CommonHelpers.parse('[1, 2, 3].reverse')) }

      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
      it { expect(annotated_node2.annotation).to eq Analist::Annotation.new(Array, [], Array) }
    end

    context 'when annotating nested statements' do
      subject(:expression) { '[1] + ["a"]' }

      it { expect(annotation).to eq Analist::Annotation.new(Array, [Array], Array) }
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

    context 'when annotating a variable' do
      let(:expression) { 'var' }

      it do
        expect(annotation).to eq Analist::Annotation.new(nil, [], Analist::AnnotationTypeUnknown)
      end
    end

    context 'when annotating a variable assignment' do
      let(:expression) { 'var = 1' }

      it { expect(annotation).to eq Analist::Annotation.new(nil, [], Integer) }
    end

    context 'when annotating a variable assignment and reference' do
      let(:expression) { 'var = 1 ; var + 1' }

      it do
        expect(annotated_node.children[0].annotation).to eq Analist::Annotation.new(
          nil, [], Integer
        )
      end
      it do
        expect(annotated_node.children[1].annotation).to eq Analist::Annotation.new(
          Integer, [Integer], Integer
        )
      end
    end

    context 'with regards to scopes in blocks' do
      let(:expression) { 'var = 1 ; [].each { var ; var = "a"; var } ; var' }

      it do
        expect(annotated_node.children[0].annotation).to eq(
          Analist::Annotation.new(nil, [], Integer)
        )
      end
      it do
        expect(annotated_node.children[1].children[2].children[0].annotation).to eq(
          Analist::Annotation.new(nil, [], Integer)
        )
      end
      it do
        expect(annotated_node.children[1].children[2].children[1].annotation).to eq(
          Analist::Annotation.new(nil, [], String)
        )
      end
      it do
        expect(annotated_node.children[1].children[2].children[2].annotation).to eq(
          Analist::Annotation.new(nil, [], String)
        )
      end
      it do
        expect(annotated_node.children[2].annotation).to eq(
          Analist::Annotation.new(nil, [], Integer)
        )
      end
    end
  end
end
