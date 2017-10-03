# frozen_string_literal: true

require 'pry'
require 'parser/ruby24'
require 'pg_query'

require_relative '../lib/analist/analyzer'

class CommonHelpers
  def self.parse(args)
    Parser::Ruby24.parse(args)
  end

  def self.parse_sql(filename)
    PgQuery.parse(File.read(filename)).tree
  end
end
