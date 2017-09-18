require 'pry'
require 'parser/ruby24'
require 'optparse'
require 'ostruct'

require_relative './analyze/coerce'
require_relative './analyze/binary_operator'
require_relative './analyze/method'
require_relative './analyze/send'
require_relative './analyze/errors'
require_relative './ast/def_node'
require_relative './ast/send_node'

class Analyzer
  def analyze # rubocop:disable Metric/AbcSize
    errors = []

    errors << main_invocations.map { |func| Analyze::Send.new(functions, func).errors }
    errors << functions.values.map { |func| Analyze::Method.new(func).errors }

    print_errors(errors.flatten.compact)
  end

  def main_invocations
    parser.children.select { |c| c.type == :send }.map do |i|
      AST::SendNode.new(i)
    end
  end

  def functions
    parser.children.select { |c| c.type == :def }.each_with_object({}) do |f, h|
      def_node = AST::DefNode.new(f)
      h[def_node.name] = def_node
      h
    end
  end

  def print_errors(errors)
    errors.flatten.each do |error|
      puts "#{options[:file]}:#{error}"
      puts '  ' + source_code.split("\n")[error.line - 1]
      puts '---'
    end
  end

  private

  def source_code
    @source_code ||= IO.read(options[:file])
  end

  def parser
    @parser ||= Parser::Ruby24.parse(source_code)
  end

  def options
    @option ||= begin
      options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: example.rb'
        opts.on('-f', '--file FILE') do |file|
          options[:file] = file
        end
      end.parse!
      options
    end
  end
end

Analyzer.new.analyze
