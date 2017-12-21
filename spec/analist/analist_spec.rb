# frozen_string_literal: true

RSpec.describe Analist do
  describe '#parse' do
    context 'when having a syntax error' do
      subject(:node) { described_class.parse('1 +') }

      it { expect(-> { node.run }).to terminate.with_code(1) }
    end

    context 'when not having a syntax error' do
      subject(:node) { described_class.parse('1 + 1') }

      it { expect(node).to be_a Parser::AST::Node }
    end
  end
end
