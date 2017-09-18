RSpec.describe Analyze::Send do
  describe '#errors' do
    subject(:send) { described_class.new(functions, func) }

    let(:functions) do
      {
        method: AST::DefNode.new(CommonHelpers.parse('def method(arg1, arg2); end'))
      }
    end

    describe 'with no args' do
      let(:func) { AST::SendNode.new(CommonHelpers.parse('method')) }

      it { expect(send.errors.first).to be_kind_of Analyze::ArgumentError }
      it { expect(send.errors.first.expected_number_of_args).to be 2 }
      it { expect(send.errors.first.actual_number_of_args).to be 0 }
    end

    describe 'with one arg' do
      let(:func) { AST::SendNode.new(CommonHelpers.parse('method(arg1)')) }

      it { expect(send.errors.first).to be_kind_of Analyze::ArgumentError }
      it { expect(send.errors.first.expected_number_of_args).to be 2 }
      it { expect(send.errors.first.actual_number_of_args).to be 1 }
    end

    describe 'with two args' do
      let(:func) { AST::SendNode.new(CommonHelpers.parse('method(arg1, arg2)')) }

      it { expect(send.errors).to be_empty }
    end
  end
end
