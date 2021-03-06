# frozen_string_literal: true

require 'rspec/que/queue_up'

module RSpec
  module Que
    def queue_up(job_class)
      Matchers::QueueUp.new(job_class)
    end

    def purge_jobs
      ::Que.execute "DELETE FROM que_jobs"
    end
  end
end
