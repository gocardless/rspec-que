require File.expand_path('../lib/rspec/que/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name = 'rspec-que'
  s.version = RSpec::Que::VERSION
  s.date = Date.today.strftime('%Y-%m-%d')
  s.authors = ['GoCardless Engineering']
  s.email = ['developers@gocardless.com']
  s.summary = 'RSpec matchers to test Que'
  s.description = <<-EOL
    RSpec matchers for Que:
    * expect { method }.to queue_up(MyJob).with(some_arguments)
  EOL
  s.homepage = 'http://github.com/gocardless/rspec-que'
  s.license = 'MIT'

  s.has_rdoc = false
  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = %w(lib)

  s.add_runtime_dependency('rspec-mocks')

  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-its')
  s.add_development_dependency('rubocop')
end
