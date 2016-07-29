require 'rspec/mocks/argument_list_matcher'
require 'time'

module RSpec
  module Que
    module Matchers
      class QueueUp
        include RSpec::Matchers::Composable

        def initialize(job_class = nil)
          @matchers = [QueuedSomething.new]
          @matchers << QueuedClass.new(job_class) if job_class
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
          @matched_jobs.any?
        end

        def with(*args)
          @matchers << QueuedArgs.new(args)
          self
        end

        def at(the_time)
          matcher = QueuedAt.new(the_time)
          @matchers << matcher
          self
        end

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
          @matchers.map(&:desc).join(" ")
        end

        def format_job(job)
          "#{job[:job_class]}[" + job[:args].join(", ") + "]"
        end

        class QueuedSomething
          def matches?(_job)
            true
          end

          def desc
            "a job"
          end

          def failed_msg(_last_found)
            "nothing"
          end
        end

        class QueuedClass
          attr_reader :job_class
          def initialize(job_class)
            @job_class = job_class
          end

          def matches?(job)
            job[:job_class] == job_class.to_s
          end

          def desc
            "of class #{job_class}"
          end

          def failed_msg(candidates)
            classes = candidates.map { |c| c[:job_class] }
            if classes.length == 1
              classes.first
            else
              "#{classes.length} jobs of class [#{classes.join(', ')}]"
            end
          end
        end

        class QueuedArgs
          def initialize(args)
            @args = args
            @argument_list_matcher = RSpec::Mocks::ArgumentListMatcher.new(*args)
          end

          def matches?(job)
            @argument_list_matcher.args_match?(*job[:args])
          end

          def desc
            "with args #{@args}"
          end

          def failed_msg(candidates)
            if candidates.length == 1
              "job enqueued with #{candidates.first[:args]}"
            else
              "#{candidates.length} jobs with args: " +
                candidates.map { |j| j[:args] }.to_s
            end
          end
        end

        class QueuedAt
          def initialize(the_time)
            @time = the_time
          end

          def matches?(job)
            job[:run_at] == @time
          end

          def desc
            "at #{@time}"
          end

          def failed_msg(candidates)
            if candidates.length == 1
              "job at #{candidates.first[:run_at]}"
            else
              "jobs at #{candidates.map { |c| c[:run_at] }}"
            end
          end
        end
      end
    end
  end
end
