# frozen_string_literal: true

RSpec.describe Analist::Analyze::Coerce do
  describe '#error?' do
    describe 'when checking a bare operator' do
      it do
        expect(described_class.new(operator: :+, type: :int, args: [AST::Node.new(:str)]).error?)
          .to(be true)
      end
      it do
        expect(described_class.new(operator: :+, type: :int, args: [AST::Node.new(:int)]).error?)
          .to(be false)
      end
    end

    describe 'when checking an aliased operator' do
      it do
        expect(described_class.new(operator: :+, type: :int, args: [AST::Node.new(:str)]).error?)
          .to(be true)
      end
      it do
        expect(described_class.new(operator: :+, type: :int, args: [AST::Node.new(:int)]).error?)
          .to(be false)
      end
    end
  end
end
