require 'rspec/que/enqueue_a'

module RSpec
  module Que
    def enqueue_a(job_class)
      Matchers::EnqueueA.new(job_class)
    end

    def purge_jobs
      ::Que.execute "DELETE FROM que_jobs"
    end
  end
end
