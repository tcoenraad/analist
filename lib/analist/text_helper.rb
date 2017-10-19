# frozen_string_literal: true

require 'active_support/inflector'

module Analist
  module TextHelper
    # Taken from https://github.com/bbatsov/rubocop/blob/ec3123fc3454b080e1100e35480c6466d1240fff/lib/rubocop/formatter/text_util.rb#L9
    def pluralize(count, singular, plural = nil)
      word = if count == 1 || count =~ /^1(\.0+)?$/
               singular
             else
               plural || singular.pluralize
             end

      "#{count || 0} #{word}"
    end
  end
end
