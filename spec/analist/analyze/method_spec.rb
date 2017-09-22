# frozen_string_literal: true

RSpec.describe Analist::Analyze::Method do
  describe '#errors' do
    subject(:function) { described_class.new(Analist::AST::DefNode.new(ast)) }

    context 'when working without variables' do
      let(:ast) { CommonHelpers.parse("def method; 1 + 'a'; 1 + 1; end") }

      it { expect(function.errors.first).to be_kind_of Analist::Analyze::TypeError }
    end

    context 'when working with variables' do
      let(:ast) { CommonHelpers.parse("def method; var = 'a'; 1 + var; end") }

      it { expect(function.errors.first).to be_kind_of Analist::Analyze::TypeError }
    end
  end
end
