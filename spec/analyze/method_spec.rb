RSpec.describe Analyze::Method do
  describe '#errors' do
    subject(:function) { described_class.new(AST::DefNode.new(ast)) }

    let(:ast) { CommonHelpers.parse("def method; 1 + 'a'; 1 + 1; end")  }

    it { expect(function.errors.first).to be_kind_of Analyze::TypeError }
  end
end
