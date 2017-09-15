guard :rspec, cmd: 'bundle exec rspec' do
  # RSpec files
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^spec/.+_spec\.rb})

  # Analist files
  watch(%r{^analyze/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
end
