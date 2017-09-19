# frozen_string_literal: true

module Analyze
  class Coerce
    def self.check?(operator:, type:, other_type:)
      return false if error_map[operator][type].include?(other_type)
      true
    end

    def self.error_map
      {
        :+ => {
          int: [:str],
          str: [:int]
        }
      }
    end
  end
end
