# frozen_string_literal: true

require 'pry'
require 'parser/ruby24'
require 'pg_query'

require_relative '../lib/analist/analyze/coerce'
require_relative '../lib/analist/analyze/method'
require_relative '../lib/analist/analyze/send'
require_relative '../lib/analist/ast/def_node'
require_relative '../lib/analist/ast/send_node'
require_relative '../lib/analist/sql/create_statement'
require_relative '../lib/analist/sql/schema'

class CommonHelpers
  def self.parse(args)
    Parser::Ruby24.parse(args)
  end

  def self.parse_sql(filename)
    PgQuery.parse(File.read(filename)).tree
  end
end
