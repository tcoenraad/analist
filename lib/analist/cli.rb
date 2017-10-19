# frozen_string_literal: true

require 'colorize'
require 'parser/ruby24'
require 'pry'
require 'optparse'

require 'analist/analyzer'
require 'analist/config'
require 'analist/file_finder'
require 'analist/text_helper'
require 'analist/version'

module Analist
  class CLI
    include TextHelper

    def default_options
      {
        config: './.analist.yml'
      }
    end

    def initialize
      OptionParser.new do |parser|
        parser.banner = 'Usage: example.rb'
        parser.version = Analist::VERSION

        parser.on('-s', '--schema FILE') do |file|
          options[:schema] = file
        end

        parser.on('-c', '--config FILE') do |file|
          options[:config] = file
        end
      end.parse!

      options[:files] = ARGV

      @options = default_options.merge(options)
    end

    def run # rubocop:disable Metrics/AbcSize
      puts "Inspecting #{pluralize(files.size, 'file')}"

      print_collected_errors

      puts "#{pluralize(files.size, 'file')} inspected, "\
        "#{pluralize(collected_errors.values.sum(&:count), 'error')} found"

      exit 1 if collected_errors.any?
    end

    def print_collected_errors
      collected_errors.each do |file, errors|
        errors.each do |error|
          puts "#{Analist::FileFinder.relative_path(file).blue}:#{error}"
        end
      end
    end

    def collected_errors
      @collected_errors ||= begin
        files.each_with_object({}) do |file, h|
          errors = Analist::Analyzer.analyze(ast(file),
                                             schema_filename: options.fetch(:schema, nil))
          h[file] = errors if errors&.any?
          h
        end
      end
    end

    def to_ast(file)
      Parser::Ruby24.parse(IO.read(file))
    end

    def config
      @config ||= Analist::Config.new(options[:config])
    end

    def files
      @files ||= begin
        excluded_files = Dir.glob(config.excluded_files).map { |f| File.expand_path(f) }
        Analist::FileFinder.find(options[:files]) - excluded_files
      end
    end
  end
end
