guard :rspec, cmd: 'bundle exec rspec' do
  # RSpec files
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^spec/analyze*/.+_spec\.rb})

  # Analist files
  watch(%r{^analyze/(.+)\.rb$}) { |m| "spec/analyze/#{m[1]}_spec.rb" }
end
