# frozen_string_literal: true

RSpec.describe Analyze::Coerce do
  describe '.check?' do
    it { expect(described_class.check?(operator: :+, type: :int, other_type: :str)).to be false }
    it { expect(described_class.check?(operator: :+, type: :int, other_type: :int)).to be true }
  end
end
