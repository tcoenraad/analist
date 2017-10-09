# frozen_string_literal: true

require 'bundler/setup'
require 'analist'

RSpec.configure(&:disable_monkey_patching!)

require 'pry'
require 'parser/ruby24'
require 'pg_query'

class CommonHelpers
  def self.parse(args)
    Parser::Ruby24.parse(args)
  end

  def self.parse_sql(filename)
    PgQuery.parse(File.read(filename)).tree
  end
end
