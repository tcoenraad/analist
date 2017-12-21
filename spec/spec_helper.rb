# frozen_string_literal: true

require 'bundler/setup'
require 'analist'

# RSpec.configure(&:disable_monkey_patching!)

require 'pry'
require 'parser/ruby24'
require 'pg_query'

Dir[File.dirname(__FILE__) + '/support/matchers/*.rb'].each { |f| require f }

class CommonHelpers
  def self.parse(string)
    Analist::Explorer.expand(Parser::Ruby24.parse(string), 'filename.rb')
  end

  def self.parse_file(file)
    parse(IO.read(file))
  end

  def self.parse_sql(filename)
    PgQuery.parse(IO.read(filename)).tree
  end
end
