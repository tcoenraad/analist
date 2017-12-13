# frozen_string_literal: true

RSpec.describe Analist::Annotator do
  describe '#annotate' do
    subject(:annotation) { annotated_node.annotation }

    let(:resources) { { schema: schema, headers: headers, symbol_table: symbol_table } }
    let(:schema) { Analist::SQL::Schema.new  }
    let(:headers) { Analist::HeaderTable.new }
    let(:symbol_table) { Analist::SymbolTable.new }
    let(:annotated_node) { described_class.annotate(CommonHelpers.parse(expression), resources) }

    context 'when annotating an unknown function call' do
      let(:expression) { 'unknown_function(arg)' }

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::TypeUnknown }
    end

    context 'when annotating an unknown property on a variable' do
      let(:expression) { 'var.property' }

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::TypeUnknown }
    end

    context 'when annotating an unknown property on a known method' do
      let(:expression) { 'all.property' }

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::TypeUnknown }
    end

    context 'when annotating an unknown property on a primitive type' do
      let(:expression) { '1.unknown_property' }

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::TypeUnknown }
    end

    context 'when annotating an unknown property on a Active Record object' do
      let(:expression) { 'User.first.unknown_property' }

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::TypeUnknown }
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

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::TypeUnknown }
    end

    context 'when annotating a simple calculation' do
      subject(:expression) { '1 + 1' }

      it { expect(annotation).to eq Analist::Annotation.new(Integer, [Integer], Integer) }
    end

    context 'when annotating a regex' do
      let(:expression) { '/[aeiou]/' }

      it { expect(annotation.return_type[:type]).to eq Regexp }
    end

    context 'when annotating a boolean method call' do
      let(:expression) { '1.is_a?(String)' }

      it { expect(annotation.return_type[:type]).to eq Analist::Annotation::Boolean }
    end

    context 'when annotating a simple method call' do
      subject(:expression) { '"word".reverse' }

      it { expect(annotation).to eq Analist::Annotation.new(String, [], String) }
    end

    context 'when annotating a method call that accepts both recognized and other recipients' do
      context 'when with recognized recipient' do
        subject(:expression) { '[1,2,3].join("/")' }

        it do
          expect(annotation).to eq(Analist::Annotation.new({ type: Array, on: :collection },
                                                           [Analist::Annotation::AnyArgs],
                                                           String))
        end
      end

      context 'when with unknown recipient' do
        subject(:expression) { 'Pathname.new("dir").join("/sub")' }

        it do
          expect(annotation).to eq(Analist::Annotation.new({ type: :Pathname, on: :collection },
                                                           [Analist::Annotation::AnyArgs],
                                                           Analist::Annotation::TypeUnknown))
        end
      end
    end

    context 'when annotating a method call that accepts both string and symbol arguments' do
      context 'when symbol' do
        subject(:expression) { '1.respond_to?(:+)' }

        it do
          expect(annotation).to eq(Analist::Annotation.new(Integer, Set.new([[String], [Symbol]]),
                                                           Analist::Annotation::Boolean))
        end
      end

      context 'when string' do
        subject(:expression) { '1.respond_to?("+")' }

        it do
          expect(annotation).to eq(Analist::Annotation.new(Integer, Set.new([[String], [Symbol]]),
                                                           Analist::Annotation::Boolean))
        end
      end
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

    context 'when annotating a known database property on a Active Record object' do
      let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }
      let(:expression) { 'User.first.id' }

      it do
        expect(annotation).to eq(
          Analist::Annotation.new({ type: :User, on: :instance }, [], Integer)
        )
      end
    end

    context 'when annotating a known database property on a Active Record collection' do
      let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }
      let(:expression) { 'User.id' }

      it do
        expect(annotation).to eq(Analist::Annotation.new({ type: :User, on: :collection }, [],
                                                         Analist::Annotation::TypeUnknown))
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

    context 'when annotating a user-defined instance method' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }

      let(:expression) { 'User.first.full_name' }

      it do
        expect(annotation).to eq Analist::Annotation.new({ type: :User, on: :instance }, [], String)
      end
    end

    context 'when annotating a user-defined instance method as class method' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }

      let(:expression) { 'User.full_name' }

      it do
        expect(annotation).to eq Analist::Annotation.new({ type: :User, on: :collection }, [],
                                                         Analist::Annotation::TypeUnknown)
      end
    end

    context 'when annotating a user-defined class method on a Active Record collection' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }

      let(:expression) { 'User.anonymous_name' }

      it do
        expect(annotation).to eq Analist::Annotation.new({ type: :User, on: :collection }, [],
                                                         String)
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
          Analist::Annotation.new(nil, [], type: Array, on: :collection)
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
        expect(annotation).to eq Analist::Annotation.new(nil, [], Analist::Annotation::TypeUnknown)
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

    context 'when annotating a variable assignment and reference on an Active Record object' do
      let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }

      let(:expression) { 'var = User.first ; var.id' }

      it do
        expect(annotated_node.children[0].annotation).to eq Analist::Annotation.new(
          nil, [], type: :User, on: :instance
        )
      end
      it do
        expect(annotated_node.children[1].annotation).to eq Analist::Annotation.new(
          { type: :User, on: :instance }, [], Integer
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

    context 'when annotating klass.rb' do
      subject(:annotated_node) do
        described_class.annotate(node, resources)
      end

      let(:node) { Analist.parse_file('./spec/support/src/klass.rb') }
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/klass.rb') }

      context 'when annotating methods, handle internal references w.r.t. instance methods' do
        let(:instance_random_number_alias_node) do
          annotated_node.children[2].children[2].children
        end
        let(:class_random_number_alias_node) do
          annotated_node.children[2].children[3].children
        end

        it { expect(instance_random_number_alias_node[0]).to eq(:instance_random_number_alias) }
        it do
          expect(instance_random_number_alias_node[2].annotation).to eq(
            Analist::Annotation.new(nil, [], Integer)
          )
        end

        it { expect(class_random_number_alias_node[1]).to eq(:class_random_number_alias) }
        it do
          expect(class_random_number_alias_node[3].annotation).to eq(
            Analist::Annotation.new(nil, [], Analist::Annotation::TypeUnknown)
          )
        end
      end

      context 'when annotating methods, handle internal references w.r.t. class methods' do
        let(:instance_qotd_alias_node) do
          annotated_node.children[2].children[4].children
        end
        let(:class_qotd_alias_node) do
          annotated_node.children[2].children[5].children
        end

        it { expect(instance_qotd_alias_node[0]).to eq(:instance_qotd_alias) }
        it do
          expect(instance_qotd_alias_node[2].annotation).to eq(
            Analist::Annotation.new(nil, [], Analist::Annotation::TypeUnknown)
          )
        end

        it { expect(class_qotd_alias_node[1]).to eq(:class_qotd_alias) }
        it do
          expect(class_qotd_alias_node[3].annotation).to eq(
            Analist::Annotation.new(nil, [], String)
          )
        end
      end

      context 'when annotating recursive methods' do
        subject(:recursive_node) do
          annotated_node.children[2].children[6].children
        end

        it { expect(recursive_node[0]).to eq(:recursive_method) }
        it do
          expect(recursive_node[2].annotation).to eq(
            Analist::Annotation.new(nil, [], Analist::Annotation::TypeUnknown)
          )
        end
      end

      context 'when annotating methods recursive methods' do
        subject(:recursive_node) do
          annotated_node.children[2].children[7].children
        end

        it { expect(recursive_node[0]).to eq(:calling_recursive_method) }
        it do
          expect(recursive_node[2].annotation).to eq(
            Analist::Annotation.new(nil, [], Analist::Annotation::TypeUnknown)
          )
        end
      end

      context 'when annotating rescued methods' do
        subject(:recursive_node) do
          annotated_node.children[2].children[8].children
        end

        it { expect(recursive_node[0]).to eq(:rescued_method) }
        it do
          expect(recursive_node[2].annotation).to eq(
            Analist::Annotation.new(nil, [], Analist::Annotation::TypeUnknown)
          )
        end
      end
    end

    context 'when annotating variable assignment with object creation' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/klass.rb') }
      let(:expression) { 'var = Klass.new ; var.random_number' }

      it do
        expect(annotated_node.children[0].annotation).to eq Analist::Annotation.new(
          nil, [], type: :Klass, on: :instance
        )
      end
      it do
        expect(annotated_node.children[1].annotation).to eq Analist::Annotation.new(
          { type: :Klass, on: :instance }, [], Integer
        )
      end
    end

    context 'when annotating a forgotten decorator' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }
      let(:expression) { 'User.first.short_name' }

      it do
        expect(annotated_node.annotation.hint).to eq Analist::ResolveLookup::Hint::Decorate
      end
    end

    context 'when annotating a decorated method' do
      let(:headers) { Analist::HeaderTable.read_from_file('./spec/support/src/user.rb') }
      let(:expression) { 'User.first.decorate.short_name' }

      it do
        expect(annotated_node.annotation).to eq Analist::Annotation.new(
          { type: :UserDecorator, on: :instance }, [], String
        )
      end
    end

    context 'when annotating an inlined erb file' do
      before do
        allow(Analist::Explorer).to receive(:template_path)
          .and_return('./spec/support/src/users_edit.erb')
      end

      subject(:annotated_node) { described_class.annotate(explored_file, resources) }

      let(:schema) { Analist::SQL::Schema.read_from_file('./spec/support/sql/users.sql') }
      let(:explored_file) { Analist::Explorer.explore('./spec/support/src/users_controller.rb') }
      let(:annotated_edit_node) { annotated_node.children[2].children }

      it { expect(annotated_edit_node[0]).to eq :edit }
      it do
        expect(annotated_edit_node[3].annotation).to eq Analist::Annotation.new(
          { type: :User, on: :instance }, [], Integer
        )
      end
    end
  end
end
