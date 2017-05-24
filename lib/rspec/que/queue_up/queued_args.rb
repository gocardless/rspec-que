# frozen_string_literal: true

module RSpec
  module Que
    module Matchers
      class QueueUp
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
      end
    end
  end
end
