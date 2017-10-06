# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  # RSpec files
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^spec/analist/*/.+_spec\.rb})

  # Analist files
  watch(%r{^lib/analist/(.+)\.rb$}) { |m| "spec/analist/#{m[1]}_spec.rb" }
  watch(%r{^lib/analist/(.+)/(.+)\.rb$}) { |m| "spec/analist/#{m[1]}/#{m[2]}_spec.rb" }
end
