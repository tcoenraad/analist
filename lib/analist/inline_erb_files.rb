# frozen_string_literal: true

require 'analist/node'

module Analist
  module InlineErbFiles
    module_function

    def inline(node, filename, namespace = [])
      return node unless node.respond_to?(:type)

      case node.type
      when :class
        inline_class(node, filename, namespace)
      when :def
        inline_def(node, filename, namespace)
      when :module
        inline_module(node, filename, namespace)
      else
        inline_children(node, filename, namespace)
      end
    end

    def inline_block(node, filename, namespace, name = nil)
      namespace << name
      block = inline_children(node, filename, namespace)
      namespace.pop
      block
    end

    def inline_children(node, filename, namespace)
      Analist::Node.new(node.type, node.children.map { |n| inline(n, filename, namespace) },
                        location: node.location, filename: filename)
    end

    def inline_class(node, filename, namespace)
      inline_block(node, filename, namespace, node.children.first.children[1])
    end

    def inline_def(node, filename, namespace)
      node = inline_block(node, filename, namespace, name)

      name = node.children.first
      if %i[index new edit show destroy].include?(name)
        path = File.join(['app', 'views', namespace_to_template(namespace), "#{name}.html.erb"])
        if File.exist?(path)
          src = Analist::RubyExtractor.extract_file(path)
          erb_node = Analist.parse(src)
          node = node.concat(inline_children(erb_node, path, namespace))
        end
      end

      node
    end

    def inline_module(node, filename, namespace)
      inline_block(node, filename, namespace, node.children.first.children[1])
    end

    def namespace_to_template(namespace)
      namespace.map { |n| n.to_s.downcase.chomp('controller') }
    end
  end
end
