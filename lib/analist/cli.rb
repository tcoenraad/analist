# frozen_string_literal: true

require 'colorize'
require 'parser/ruby24'
require 'pry'
require 'optparse'

require 'analist/analyzer'
require 'analist/file_finder'
require 'analist/text_helper'
require 'analist/version'

module Analist
  class CLI
    include TextHelper

    def run # rubocop:disable Metrics/AbcSize
      puts "Inspecting #{pluralize(options[:files].size, 'file')}"

      print_results

      puts "#{pluralize(options[:files].size, 'file')} inspected, "\
        "#{pluralize(collected_errors.values.sum(&:count), 'error')}"

      exit 1 if collected_errors.any?
    end

    def print_results
      collected_errors.each do |file, errors|
        errors.each do |error|
          puts "#{Analist::FileFinder.relative_path(file).blue}:#{error}"
        end
      end
    end

    def collected_errors
      @collected_errors ||= begin
        options[:files].each_with_object({}) do |file, h|
          errors = Analist::Analyzer.analyze(ast(file),
                                             schema_filename: options.fetch(:schema, nil))
          h[file] = errors if errors&.any?
          h
        end
      end
    end

    def ast(file)
      Parser::Ruby24.parse(IO.read(file))
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
        end.parse!

        options[:files] = Analist::FileFinder.find(ARGV)

        options
      end
    end
  end
end
