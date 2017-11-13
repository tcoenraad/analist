# frozen_string_literal: true

module Analist
  class RubyExtractor
    def self.extract(string)
      string.scan(erb_to_ruby_regex).join("\n")
    end

    def self.extract_file(file)
      extract(IO.read(file))
    end

    def self.erb_to_ruby_regex
      /<%(?:=|-)?\s*(.+?)\s*%>/
    end
  end
end
