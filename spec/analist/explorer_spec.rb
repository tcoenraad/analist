# frozen_string_literal: true

RSpec.describe Analist::Explorer do
  describe '#expand' do
    subject(:explored_file) { described_class.explore('./spec/support/src/users_controller.rb') }

    context 'when inlining erb files' do
      before do
        allow(described_class).to receive(:template_path)
          .and_return('./spec/support/src/users_edit.erb')
      end

      let(:edit_node) { explored_file.children[2].children }

      it { expect(edit_node[0]).to eq :edit }
      it { expect(edit_node[3]).to eq CommonHelpers.parse('User.first.id') }
    end
  end
end
