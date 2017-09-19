# frozen_string_literal: true

RSpec.describe Analyze::Coerce do
  describe '.check?' do
    describe 'when checking a bare operator' do
      it do
        expect(described_class.check?(operator: :+, left_type: :int, right_type: :str)).to be false
      end
      it do
        expect(described_class.check?(operator: :+, left_type: :int, right_type: :int)).to be true
      end
    end

    describe 'when checking an aliased operator' do
      it do
        expect(described_class.check?(operator: :+, left_type: :int, right_type: :str)).to be false
      end
      it do
        expect(described_class.check?(operator: :+, left_type: :int, right_type: :int)).to be true
      end
    end
  end
end
