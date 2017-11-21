# frozen_string_literal: true

RSpec.describe Analist::Config do
  describe '#accessors' do
    context 'when lacking an config file' do
      it { expect(described_class.new.excluded_files).to be_empty }
      it { expect(described_class.new.global_types).to be_empty }
    end

    context 'when using an non-existing config file' do
      let(:yml) { './spec/support/config/non_existing.yml' }

      it { expect(described_class.new(yml).excluded_files).to be_empty }
      it { expect(described_class.new(yml).global_types).to be_empty }
    end

    context 'when using an config file without exclude files section' do
      let(:yml) { './spec/support/config/empty_sections.yml' }

      it { expect(described_class.new(yml).excluded_files).to be_empty }
      it { expect(described_class.new(yml).global_types).to be_empty }
    end

    context 'when using an config file with exclude files section' do
      let(:yml) { './.analist.yml' }

      it do
        expect(described_class.new(yml).excluded_files).to eq(
          %w[example.rb vendor/**/*]
        )
      end
    end

    context 'when using an config file with globally defined section' do
      let(:yml) { './.analist.yml' }

      it do
        expect(described_class.new(yml).global_types).to eq(
          administration: :Administration
        )
      end
    end
  end
end
