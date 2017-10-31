# frozen_string_literal: true

RSpec.describe Analist::HeaderTable do
  subject(:header_table) { described_class.new }

  describe '#retrieve_class' do
    it { expect(header_table.retrieve_class('NonExistingClass')).to be_nil }
  end

  describe '#retrieve_method' do
    before do
      header_table.store_class(:Class, superklass: 'Superclass')
      header_table.store_method(:method, [:Class], :node)
      header_table.store_method(:inherited_method, [:Superclass], :abstract_node)
    end

    it { expect(header_table.retrieve_method(:method, 'NonExistingClass')).to be_nil }
    it { expect(header_table.retrieve_method(:non_existing_method, 'Class')).to be_nil }
    it { expect(header_table.retrieve_method(:inherited_method, 'Class')).to eq :abstract_node }
  end

  describe '#store_class' do
    before { header_table.store_class(:Class, scope: [:Module], superklass: :Superclass) }

    it { expect(header_table.retrieve_class('Module::Class')[:scope]).to eq [:Module] }
    it { expect(header_table.retrieve_class('Module::Class')[:superklass]).to eq :Superclass }
  end

  describe '#store_method' do
    context 'when storing a method on one class' do
      before { header_table.store_method(:method, [:Class], :node) }

      it { expect(header_table.retrieve_method(:method, 'Class')).to eq :node }
    end

    context 'when storing a method on two class' do
      before do
        header_table.store_method(:method, [:Class], :node)
        header_table.store_method(:method, [:SecondClass], :second_node)
      end

      it { expect(header_table.retrieve_method(:method, 'Class')).to eq :node }
      it { expect(header_table.retrieve_method(:method, 'SecondClass')).to eq :second_node }
    end
  end
end
