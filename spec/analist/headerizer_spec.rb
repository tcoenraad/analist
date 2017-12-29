# frozen_string_literal: true

RSpec.describe Analist::Headerizer do
  let(:source) { CommonHelpers.parse_file('./spec/support/src/modules_and_classes.rb') }

  describe '#headerizer' do
    subject(:header_table) { described_class.headerize([source]) }

    context 'with regard to the User class' do
      it { expect(header_table.retrieve_class('User').superklass).to eq '' }
      it { expect(header_table.retrieve_class('User').scope).to be_empty }
    end

    context 'with regard to the BlaatUser class' do
      it { expect(header_table.retrieve_class('Blaat::BlaatUser').superklass).to eq 'User' }
      it { expect(header_table.retrieve_class('Blaat::BlaatUser').scope).to eq [:Blaat] }
      it { expect(header_table.retrieve_method(:method, 'Blaat::BlaatUser')).not_to be_nil }
    end

    context 'with regard to the SuperBlaatUser class' do
      it { expect(header_table.retrieve_class('Blaat::SuperBlaatUser').superklass).to eq 'User' }
      it { expect(header_table.retrieve_class('Blaat::SuperBlaatUser').scope).to eq [:Blaat] }
      it { expect(header_table.retrieve_method(:method, 'Blaat::SuperBlaatUser')).to be_nil }
      it { expect(header_table.retrieve_method(:full_name, 'Blaat::SuperBlaatUser')).not_to be_nil }
    end

    context 'with regard to the User mutation classes' do
      it { expect(header_table.retrieve_mutation('CreateUser.id')).to eq Integer }
      it { expect(header_table.retrieve_mutation('CreateUser.name')).to eq String }
      it { expect(header_table.retrieve_mutation('UpdateUser.id')).to eq Integer }
    end
  end
end
