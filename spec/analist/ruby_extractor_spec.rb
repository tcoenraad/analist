# frozen_string_literal: true

RSpec.describe Analist::RubyExtractor do
  describe '#extract' do
    subject(:extracted_ruby) { described_class.extract(source) }

    context 'when using <%=' do
      context 'with proper spacing' do
        let(:source) { '<%= some_ruby %>' }

        it { expect(extracted_ruby).to eq 'some_ruby;' }
      end

      context 'without proper spacing' do
        let(:source) { '<%=some_ruby%>' }

        it { expect(extracted_ruby).to eq 'some_ruby;' }
      end

      context 'with multiple statements in one line' do
        let(:source) { '<%= some_ruby%> <%= some_more_ruby %>' }

        it { expect(extracted_ruby).to eq 'some_ruby;some_more_ruby;' }
      end
    end

    context 'when using <%' do
      let(:source) { '<% some_ruby %>' }

      it { expect(extracted_ruby).to eq 'some_ruby;' }
    end

    context 'when using <%-' do
      let(:source) { '<%- some_ruby %>' }

      it { expect(extracted_ruby).to eq 'some_ruby;' }
    end
  end
end
