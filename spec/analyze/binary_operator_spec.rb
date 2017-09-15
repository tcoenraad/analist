RSpec.describe Analyze::BinaryOperator do
  subject { described_class.new(ast.children) }

  describe '#operator' do
    let(:ast) { CommonHelpers.parse("'a' + 1") }
    it { expect(subject.operator).to be :+ }
  end

  describe '#type' do
    let(:ast) { CommonHelpers.parse("'a' + 1") }
    it { expect(subject.left.type).to be :str }
  end

  describe '#type' do
    let(:ast) { CommonHelpers.parse("'a' + 1") }
    it { expect(subject.right.type).to be :int }
  end

  describe '#errors' do
    context 'with coerce error' do
      let(:ast) { CommonHelpers.parse("'a' + 1") }
      it { expect(subject.errors.first).to be_kind_of Analyze::TypeError }
      it { expect(subject.errors.first.line).to be 1 }
    end

    context 'without coerce error' do
      let(:ast) { CommonHelpers.parse("'a' + '1'") }
      it { expect(subject.errors).to be nil }
    end
  end
end
