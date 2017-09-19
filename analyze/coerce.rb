# frozen_string_literal: true

module Analyze
  class Coerce
    def self.check?(operator:, type:, other_type:)
      return false if error_map[aliases_map[operator]][type] &&
                      error_map[operator][type].include?(other_type)
      true
    end

    def self.error_map
      {
        :+ => {
          int: [:str],
          str: [:int],
          hash: [:array],
          array: [:hash]
        }
      }
    end

    def self.aliases_map
      {
        :+ => :+,
        :- => :+,
        :* => :+,
        :/ => :+
      }
    end
  end
end
