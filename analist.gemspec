# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'analist/version'

Gem::Specification.new do |spec|
  spec.name          = 'analist'
  spec.version       = Analist::VERSION
  spec.authors       = ['Twan Coenraad']
  spec.email         = ['tcoenraad@users.noreply.github.com']

  spec.summary       = 'A static analysis tool for Ruby.'
  spec.homepage      = 'https://github.com/tcoenraad/analist'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~> 5.0'
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'parser', '~> 2.4.0.0'
  spec.add_runtime_dependency 'pg_query', '~> 0.13.5'

  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'terminal-notifier-guard'
end
