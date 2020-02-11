# frozen_string_literal: true

module RSpec
  module Que
    module Matchers
      class QueueUp
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
