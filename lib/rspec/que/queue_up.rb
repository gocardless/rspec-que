# frozen_string_literal: true

require 'rspec/mocks/argument_list_matcher'
require 'time'
require 'forwardable'

require_relative 'queue_up/queued_something'
require_relative 'queue_up/queued_priority'
require_relative 'queue_up/queued_class'
require_relative 'queue_up/queued_args'
require_relative 'queue_up/queued_at'
require_relative 'queue_up/queue_count'

module RSpec
  module Que
    module Matchers
      class QueueUp
        include RSpec::Matchers::Composable
        extend Forwardable

        def initialize(job_class = nil)
          @matchers = [QueuedSomething.new]
          @matchers << QueuedClass.new(job_class) if job_class
          @count_matcher = QueueCount.new(self, QueueCount::EXACTLY, 1)
          @job_class = job_class
          @stages = []
        end

        def matches?(block)
          before_jobs = enqueued_jobs.dup
          block.call

          @matched_jobs = enqueued_jobs - before_jobs
          @matchers.each do |matcher|
            @stages << { matcher: matcher, candidates: @matched_jobs.dup }
            @matched_jobs.delete_if { |job| !matcher.matches?(job) }
          end

          @stages << { matcher: @count_matcher, candidates: @matched_jobs.dup }

          @count_matcher.matches?(@matched_jobs.count)
        end

        def with(*args)
          @matchers << QueuedArgs.new(args)
          self
        end

        def at(the_time)
          @matchers << QueuedAt.new(the_time)
          self
        end

        def of_priority(priority)
          @matchers << QueuedPriority.new(priority)
          self
        end

        def_delegators :@count_matcher,
                       :exactly,
                       :at_least,
                       :at_most,
                       :once,
                       :twice

        def failure_message
          # last stage to have any candidate jobs
          failed_stage = @stages.reject do |s|
            s[:candidates].empty?
          end.last || @stages.first
          failed_matcher = failed_stage[:matcher]
          failed_candidates = failed_stage[:candidates]
          found_instead = failed_matcher.failed_msg(failed_candidates)

          "expected to enqueue #{job_description}, but found #{found_instead}"
        end

        def failure_message_when_negated
          format "expected not to enqueue #{job_description}, got %d enqueued: %s",
                 @matched_jobs.length,
                 @matched_jobs.map { |j| format_job(j) }.join(", ")
        end

        def supports_block_expectations?
          true
        end

        def description
          "queues up a #{job_description}"
        end

        private

        attr_reader :before_count, :after_count, :job_class, :argument_list_matcher

        def enqueued_jobs
          ::Que.execute "SELECT * FROM que_jobs"
        end

        def job_description
          if @count_matcher.default?
            @matchers.map(&:desc).join(" ")
          else
            [*@matchers, @count_matcher].map(&:desc).join(" ")
          end
        end

        def format_job(job)
          "#{job[:job_class]}[" + job[:args].join(", ") + "]"
        end
      end
    end
  end
end
