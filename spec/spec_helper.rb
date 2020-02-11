# frozen_string_literal: true

require 'rspec/que'
require 'pry'

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.disable_monkey_patching!
end

module Que
  def self.execute(args)
    # Que placeholder
  end
end
