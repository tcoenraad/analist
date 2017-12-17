# frozen_string_literal: true

require 'colorize'
require 'optparse'
require 'tempfile'

require 'analist'
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

        parser.on('-i', '--stdin FILE') do |file|
          @options[:stdin] = file
        end
      end.parse!

      @options[:files] = ARGV
    end

    def default_options
      {
        config: './.analist.yml',
        schema: './db/structure.sql'
      }
    end

    def run # rubocop:disable Metrics/AbcSize
      if @options[:stdin]
        file = Tempfile.new([File.basename(@options[:stdin], '.*'), File.extname(@options[:stdin])])
        begin
          file.write(ARGF.read)
          file.rewind
          @options[:files] = [file.path]
          print_collected_errors
          error_count = 1
        ensure
          file.close
          file.unlink
        end
      else
        puts "Inspecting #{pluralize(files.size, 'file')}"

        print_collected_errors

        error_count = collected_errors.inject(0) { |sum, e| sum + e.count }
        puts "#{pluralize(files.size, 'file')} inspected, "\
          "#{pluralize(error_count, 'error')} found"
      end

      exit 1 if error_count.positive?
    end

    def print_collected_errors
      collected_errors.each do |errors|
        errors.each do |error|
          puts error
        end
      end
    end

    def collected_errors
      @collected_errors ||= begin
        Analist.analyze(files, schema_filename: @options.fetch(:schema, nil),
                               global_types: config.global_types)
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
