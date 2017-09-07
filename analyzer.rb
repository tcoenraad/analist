require 'pry'
require 'parser/ruby24'
require 'optparse'
require 'ostruct'

require_relative './coercing'
require_relative './ast/def_node'
require_relative './ast/send_node'

class Analyzer
  def analyze
    main_invocations.each do |func|
      traverse_statements(functions[func.name].body)
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

  def verify_binary_operation(statement)
    statement = OpenStruct.new(operator: statement[1], self: statement.first, other: statement.last)
    return if Coercion.check?(op: statement.operator, type: statement.self.type, other_type: statement.other.type)

    line = statement.self.loc.line
    puts "#{options[:file]}:#{line} Coerce error"
    puts source_code.split("\n")[line - 1]
  end

  def traverse_statements(statements)
    return unless statements && statements.kind_of?(Parser::AST::Node)

    case statements.type
    when :begin
      statements.children.map { |s| traverse_statements(s) }
    when :send
      first_child = statements.children.first
      if first_child && self.class.primitive_types.include?(first_child.type)
        verify_binary_operation(statements.children)
      else
        statements.children.map { |s| traverse_statements(s) }
      end
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
end

Analyzer.new.analyze
