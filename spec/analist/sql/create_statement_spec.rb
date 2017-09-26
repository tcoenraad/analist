# frozen_string_literal: true

RSpec.describe Analist::SQL::CreateStatement do
  subject(:create_statement) { described_class.new(tree.first['CreateStmt']) }

  let(:tree) { CommonHelpers.parse_sql('./spec/support/sql/users.sql') }

  describe '#table_name' do
    it { expect(create_statement.table_name).to eq 'users' }
  end

  describe '#columns' do
    it do
      expect(create_statement.columns).to include(
        'id' => %w[pg_catalog int4],
        'created_at' => %w[pg_catalog timestamp]
      )
    end
  end
end
