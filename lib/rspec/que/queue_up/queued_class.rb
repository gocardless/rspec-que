# frozen_string_literal: true

module RSpec
  module Que
    module Matchers
      class QueueUp
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
      end
    end
  end
end
