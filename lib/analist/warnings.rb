# frozen_string_literal: true

module Analist
  class DecorateWarning
    def initialize(node)
      @node = node
      receiver, @method, = node.children
      @receiver = receiver.annotation.return_type[:type]
    end

    def to_s
      "#{Analist::FileFinder.relative_path(@node.filename)}:#{@node.loc.line} DecorateWarning:" \
        "method `#{@method}' would exist when #{@receiver} is decorated"
    end
  end
end
