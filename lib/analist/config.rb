# frozen_string_literal: true

require 'yaml'

module Analist
  class Config
    def initialize(config_file = nil)
      @options = default_options.merge(read_config(config_file))
    end

    def read_config(config_file)
      return {} unless config_file && File.exist?(config_file)

      config = YAML.safe_load(IO.read(config_file))
      return {} unless config
      config.reject { |_, v| v.nil? }
    end

    def excluded_files
      @options['Exclude']
    end

    def default_options
      {
        'Exclude' => []
      }
    end
  end
end
