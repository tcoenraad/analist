# frozen_string_literal: true

require 'pry'
require 'parser/ruby24'
require 'pg_query'

require_relative '../lib/analyze/binary_operator'
require_relative '../lib/analyze/coerce'
require_relative '../lib/analyze/method'
require_relative '../lib/analyze/send'
require_relative '../lib/ast/def_node'
require_relative '../lib/ast/send_node'
require_relative '../lib/sql/create_statement'

class CommonHelpers
  def self.parse(args)
    Parser::Ruby24.parse(args)
  end

  def self.parse_sql(filename)
    PgQuery.parse(File.read(filename)).tree
  end
end
