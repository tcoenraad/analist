require 'pry'
require 'parser/ruby24'
require 'optparse'
require 'ostruct'

require_relative './coercing'
require_relative './analyze/binary_operator'
require_relative './analyze/send'
require_relative './analyze/errors'
require_relative './ast/def_node'
require_relative './ast/send_node'

class Analyzer
  attr_reader :errors

  def initialize
    @errors = []
  end

  def analyze
    main_invocations.each { |func| errors << Analyze::Send.new(functions, func).inspect! }
    main_invocations.each { |func| traverse_statements(functions[func.name].body) }

    errors.compact.each do |error|
      if error.is_a?(Analyze::TypeError)
        puts "#{options[:file]}:#{error.line} TypeError"
      elsif error.is_a?(Analyze::ArgumentError)
        puts "#{options[:file]}:#{error.line} ArgumentError, expected #{error.expected_number_of_args}, actual: #{error.actual_number_of_args}"
      end
      puts source_code.split("\n")[error.line - 1]
      puts '---'
    end
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

  def traverse_statements(statements)
    return unless statements && statements.is_a?(Parser::AST::Node)

    case statements.type
    when :begin
      handle_begin(statements)
    when :send
      handle_send(statements)
    end
  end

  def self.primitive_types
    %i[int str]
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

  def handle_begin(statements)
    statements.children.map { |s| traverse_statements(s) }
  end

  def handle_send(statements)
    first_child = statements.children.first
    if first_child && self.class.primitive_types.include?(first_child.type)
      errors << Analyze::BinaryOperator.new(statements.children).inspect!
    else
      statements.children.map { |s| traverse_statements(s) }
    end
  end
end

Analyzer.new.analyze
