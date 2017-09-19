# frozen_string_literal: true

RSpec.describe Analyze::Coerce do
  describe '.check?' do
    describe 'when checking a bare operator' do
      it { expect(described_class.check?(operator: :+, type: :int, other_type: :str)).to be false }
      it { expect(described_class.check?(operator: :+, type: :int, other_type: :int)).to be true }
    end

    describe 'when checking an aliased operator' do
      it { expect(described_class.check?(operator: :+, type: :int, other_type: :str)).to be false }
      it { expect(described_class.check?(operator: :+, type: :int, other_type: :int)).to be true }
    end
  end
end
