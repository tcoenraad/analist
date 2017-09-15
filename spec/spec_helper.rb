require 'pry'
require 'parser/ruby24'

require_relative '../analyze/binary_operator'
require_relative '../analyze/coerce'
require_relative '../analyze/send'
require_relative '../ast/def_node'
require_relative '../ast/send_node'

class CommonHelpers
  def self.parse(args)
    Parser::Ruby24.parse(args)
  end
end
