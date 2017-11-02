# frozen_string_literal: true

RSpec.describe Analist::Annotator do
  describe '#annotate' do
    subject(:annotation) { annotated_node.annotation }

    let(:resources) do
      { schema: Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql'),
        headers: Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }
    end

    let(:annotated_node) { described_class.annotate(CommonHelpers.parse(expression), resources) }

    context 'when annotating an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when annotating an unknown property on a variable' do
      let(:expression) { 'a.unknown_property' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when annotating an unknown property on a primitive type' do
      let(:expression) { '1.unknown_property' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when annotating an unknown property on a Active Record object' do
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

    context 'when annotating a calculation on an unknown property on a Active Record object' do
      let(:expression) { 'User.first.unknown_property + 1' }

      it { expect(annotation.return_type[:type]).to eq Analist::AnnotationTypeUnknown }
    end

    context 'when annotating a simple calculation' do
      subject(:expression) { '1 + 1' }

      it { expect(annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
    end

    context 'when annotating a simple method call' do
      subject(:expression) { '"word".reverse' }

      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
    end

    context 'when annotating a chained method call' do
      subject(:expression) { '"word".reverse.upcase' }

      it { expect(annotated_node).to be_instance_of Analist::AnnotatedNode }
      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
      it do
        expect(annotated_node.children.first.annotation).to eq(
          Analist::Annotation.new(String, [], String)
        )
      end
    end

    context 'when annotating a known property on a Active Record object' do
      let(:expression) { 'User.first.id' }

      it do
        expect(annotation).to eq(
          Analist::Annotation.new({ type: :User, on: :instance }, [], Integer)
        )
      end
    end

    context 'when annotating an Active Record collection' do
      let(:expression) { 'User.all' }

      it do
        expect(annotation).to eq Analist::Annotation.new(
          { type: :User, on: :collection }, [], type: :User, on: :collection
        )
      end
    end

    context 'when annotating an user-defined method' do
      let(:expression) { 'User.first.full_name' }

      it do
        expect(annotation).to eq Analist::Annotation.new({ type: :User, on: :instance }, [], String)
      end
    end

    context 'when annotating duck types, e.g. for `reverse`' do
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

    context 'when annotating blocks, handle scope' do
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

    context 'when annotating methods, handle internal references' do
      subject(:annotated_node) do
        described_class.annotate(node, headers: headers)
      end

      let(:node) { Analist.to_ast('./spec/support/src/klass.rb') }
      let(:headers) { Analist::Headerizer.headerize([node]) }

      it { expect(annotated_node.children[2].children[1].children[0]).to eq(:random_number_alias) }
      it do
        expect(annotated_node.children[2].children[1].children[2].annotation).to eq(
          Analist::Annotation.new(nil, [], Integer)
        )
      end

      it { expect(annotated_node.children[2].children[3].children[1]).to eq(:qotd_alias) }
      it do
        expect(annotated_node.children[2].children[3].children[3].annotation).to eq(
          Analist::Annotation.new(nil, [], String)
        )
      end
    end
  end
end
