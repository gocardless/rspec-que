require 'rspec/que'
require 'pry'

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.disable_monkey_patching!
end

module Que
  # rubocop:disable Lint/UnusedMethodArgument
  def self.execute(args)
    # Que placeholder
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
