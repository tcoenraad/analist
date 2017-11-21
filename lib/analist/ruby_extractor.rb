# frozen_string_literal: true

module Analist
  class RubyExtractor
    def self.extract(string)
      string.scan(erb_to_ruby_regex).flatten.map { |rb| rb.nil? ? "\n" : "#{rb};" }.join
    end

    def self.extract_file(file)
      extract(IO.read(file))
    end

    def self.erb_to_ruby_regex
      /<%(?:=|-)?\s*(.+?)\s*-?%>|\n/m
    end
  end
end
