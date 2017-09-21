# frozen_string_literal: true

require 'pry'
require 'parser/ruby24'
require 'pg_query'

require_relative '../analyze/binary_operator'
require_relative '../analyze/coerce'
require_relative '../analyze/method'
require_relative '../analyze/send'
require_relative '../ast/def_node'
require_relative '../ast/send_node'
require_relative '../lib/sql/create_statement'

class CommonHelpers
  def self.parse(args)
    Parser::Ruby24.parse(args)
  end

  def self.parse_sql(filename)
    PgQuery.parse(File.read(filename)).tree
  end
end
