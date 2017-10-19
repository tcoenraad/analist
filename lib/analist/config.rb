# frozen_string_literal: true

require 'yaml'

module Analist
  class Config
    def initialize(config_file)
      @options = default_options.merge(read_config(config_file))
    end

    def read_config(config_file)
      YAML.safe_load(IO.read(config_file)).reject { |_, v| v.nil? }
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
