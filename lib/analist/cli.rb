# frozen_string_literal: true

require 'pry'
require 'optparse'
require 'parser/ruby24'

require 'analist/analyzer'
require 'analist/version'

module Analist
  class CLI
    def run
      puts Analist::Analyzer.analyze(ast, schema_filename: options.fetch(:schema, nil))
    end

    def ast
      @ast ||= Parser::Ruby24.parse(source_code)
    end

    def source_code
      @source_code ||= IO.read(options[:file])
    end

    def options
      @options ||= begin
        options = {}
        OptionParser.new do |parser|
          parser.banner = 'Usage: example.rb'
          parser.version = Analist::VERSION

          parser.on('-s', '--schema FILE') do |file|
            options[:schema] = file
          end

          if ARGV.empty?
            puts parser
            exit
          end
        end.parse!
        options[:file] = ARGV.first if ARGV.any?

        options
      end
    end
  end
end
