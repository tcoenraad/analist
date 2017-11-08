# frozen_string_literal: true

RSpec.describe Analist::Config do
  describe '#excluded_files' do
    context 'when lacking an config file' do
      it { expect(described_class.new.excluded_files).to be_empty }
    end

    context 'when using an non-existing config file' do
      let(:empty_exclude_yml) { './spec/support/config/non_existing.yml' }

      it { expect(described_class.new(empty_exclude_yml).excluded_files).to be_empty }
    end

    context 'when using an config file without exclude files section' do
      let(:empty_exclude_yml) { './spec/support/config/empty.yml' }

      it { expect(described_class.new(empty_exclude_yml).excluded_files).to be_empty }
    end

    context 'when using an config file without exclude files section' do
      let(:empty_exclude_yml) { './spec/support/config/empty_exclude_section.yml' }

      it { expect(described_class.new(empty_exclude_yml).excluded_files).to be_empty }
    end

    context 'when using an config file without exclude files section' do
      let(:empty_exclude_yml) { './.analist.yml' }

      it do
        expect(described_class.new(empty_exclude_yml).excluded_files).to eq(
          %w[example.rb vendor/**/*]
        )
      end
    end
  end
end
