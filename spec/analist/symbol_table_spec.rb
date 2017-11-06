# frozen_string_literal: true

RSpec.describe Analist::SymbolTable do
  subject(:symbol_table) { described_class.new }

  describe '#retrieve' do
    it { expect(symbol_table.retrieve(:var)).to be_nil }
  end

  describe '#store' do
    before { symbol_table.store(:var, 'a') }

    it { expect(symbol_table.retrieve(:var)).to eq 'a' }
  end

  describe '#enter_scope' do
    before do
      symbol_table.store(:var, 'a')
      symbol_table.enter_scope
    end

    it { expect(symbol_table.retrieve(:var)).to eq 'a' }

    context 'with nested scopes' do
      before { symbol_table.enter_scope }

      it { expect(symbol_table.level).to eq 2 }
      it { expect(symbol_table.retrieve(:var)).to eq 'a' }
    end
  end

  describe '#exit_scope' do
    before do
      symbol_table.store(:var1, 'a')
      symbol_table.enter_scope
      symbol_table.store(:var2, 'b')
      symbol_table.exit_scope
    end

    it { expect(symbol_table.retrieve(:var1)).to eq 'a' }
    it { expect(symbol_table.retrieve(:var2)).to be_nil }
  end
end
