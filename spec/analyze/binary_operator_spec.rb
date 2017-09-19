# frozen_string_literal: true

RSpec.describe Analyze::BinaryOperator do
  subject(:binary_operator) { described_class.new(ast.children, {}) }

  describe '#operator' do
    let(:ast) { CommonHelpers.parse("'a' + 1") }

    it { expect(binary_operator.operator).to be :+ }
  end

  describe '#type' do
    let(:ast) { CommonHelpers.parse("'a' + 1") }

    it { expect(binary_operator.left.type).to be :str }
  end

  describe '#type' do
    let(:ast) { CommonHelpers.parse("'a' + 1") }

    it { expect(binary_operator.right.type).to be :int }
  end

  describe '#errors' do
    context 'with coerce error' do
      let(:ast) { CommonHelpers.parse("'a' + 1") }

      it { expect(binary_operator.errors.first).to be_kind_of Analyze::TypeError }
      it { expect(binary_operator.errors.first.line).to be 1 }
    end

    context 'without coerce error' do
      let(:ast) { CommonHelpers.parse("'a' + '1'") }

      it { expect(binary_operator.errors).to be_empty }
    end
  end
end
