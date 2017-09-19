# frozen_string_literal: true

module Analyze
  class Coerce
    def self.check?(operator:, left_type:, right_type:)
      return false if error_map[aliases_map[operator]][left_type] &&
                      error_map[operator][left_type].include?(right_type)
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
