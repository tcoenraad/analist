# frozen_string_literal: true

require 'analist/node'

module Analist
  module Explorer
    module_function

    def explore(filename)
      expand(Analist.parse_file(filename), filename)
    end

    def expand(node, filename, namespace = [])
      return node unless node.respond_to?(:type)

      case node.type
      when :class
        expand_class(node, filename, namespace)
      when :def
        expand_def(node, filename, namespace)
      when :module
        expand_module(node, filename, namespace)
      else
        expand_children(node, filename, namespace)
      end
    end

    def expand_block(node, filename, namespace, name = nil)
      namespace << name
      block = expand_children(node, filename, namespace)
      namespace.pop
      block
    end

    def expand_children(node, filename, namespace)
      Analist::Node.new(node.type, node.children.map { |n| expand(n, filename, namespace) },
                        location: node.location, filename: filename)
    end

    def expand_class(node, filename, namespace)
      expand_block(node, filename, namespace, node.children.first.children[1])
    end

    def expand_def(node, filename, namespace)
      method_name = node.children.first
      node = expand_block(node, filename, namespace, method_name)
      if %i[index new edit show destroy].include?(method_name)
        node = inline_template(node, namespace, method_name)
      end

      node
    end

    def expand_module(node, filename, namespace)
      expand_block(node, filename, namespace, node.children.first.children[1])
    end

    def inline_template(node, namespace, action)
      path = template_path(namespace, action)
      return node unless File.exist?(path)

      src = Analist::RubyExtractor.extract_file(path)
      erb_node = Analist.parse(src)
      node.append(expand_children(erb_node, path, namespace))
    end

    def template_path(namespace, action)
      File.join(['app', 'views', namespace_to_template(namespace), "#{action}.html.erb"])
    end

    def namespace_to_template(namespace)
      namespace.map { |n| n.to_s.downcase.chomp('controller') }
    end
  end
end
