# frozen_string_literal: true

RSpec.describe Analist::Analyze::Send do
  subject(:send) { described_class.new(func, functions: functions) }

  describe '#no_method_error' do
    let(:functions) { {} }

    context 'when invoking a non-existing methods' do
      let(:func) { Analist::AST::SendNode.new(CommonHelpers.parse('{} << 1')) }

      it { expect(send.no_method_error).to be_kind_of Analist::Analyze::NoMethodError }
    end

    context 'when invoking an existing method' do
      let(:func) { Analist::AST::SendNode.new(CommonHelpers.parse('[] << 1')) }

      it { expect(send.no_method_error).to be_nil }
    end
  end

  describe '#argument_error' do
    let(:functions) do
      {
        method: Analist::AST::DefNode.new(CommonHelpers.parse('def method(arg1, arg2); end'))
      }
    end

    context 'with no args' do
      let(:func) { Analist::AST::SendNode.new(CommonHelpers.parse('method')) }

      it { expect(send.argument_error).to be_kind_of Analist::Analyze::ArgumentError }
      it { expect(send.argument_error.expected_number_of_args).to be 2 }
      it { expect(send.argument_error.actual_number_of_args).to be 0 }
    end

    context 'with one arg' do
      let(:func) { Analist::AST::SendNode.new(CommonHelpers.parse('method(arg1)')) }

      it { expect(send.argument_error).to be_kind_of Analist::Analyze::ArgumentError }
      it { expect(send.argument_error.expected_number_of_args).to be 2 }
      it { expect(send.argument_error.actual_number_of_args).to be 1 }
    end

    context 'with two args' do
      let(:func) { Analist::AST::SendNode.new(CommonHelpers.parse('method(arg1, arg2)')) }

      it { expect(send.errors).to be_empty }
    end
  end
end
