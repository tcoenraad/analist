# frozen_string_literal: true

require 'colorize'
require 'parser/ruby24'
require 'pry'
require 'optparse'

require 'analist'
require 'analist/file_finder'
require 'analist/text_helper'

module Analist
  class CLI
    include TextHelper

    def initialize
      @options = default_options

      OptionParser.new do |parser|
        parser.banner = 'Usage: example.rb'
        parser.version = Analist::VERSION

        parser.on('-s', '--schema FILE') do |file|
          @options[:schema] = file
        end

        parser.on('-c', '--config FILE') do |file|
          @options[:config] = file
        end
      end.parse!

      @options[:files] = ARGV
    end

    def default_options
      {
        config: './.analist.yml'
      }
    end

    def run # rubocop:disable Metrics/AbcSize
      puts "Inspecting #{pluralize(files.size, 'file')}"

      print_collected_errors

      error_count = collected_errors.values.sum(&:count)
      puts "#{pluralize(files.size, 'file')} inspected, "\
        "#{pluralize(error_count, 'error')} found"

      exit 1 if error_count.positive?
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
        Analist.analyze(files, schema_filename: @options.fetch(:schema, nil))
      end
    end

    def config
      @config ||= Analist::Config.new(@options[:config])
    end

    def files
      @files ||= begin
        excluded_files = Dir.glob(config.excluded_files).map { |f| File.expand_path(f) }
        Analist::FileFinder.find(@options[:files]) - excluded_files
      end
    end
  end
end
